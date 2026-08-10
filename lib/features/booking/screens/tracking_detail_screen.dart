import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';

class TrackingDetailScreen extends StatelessWidget {
  final String bookingId;
  const TrackingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F5),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'ติดตามพัสดุ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 1. Top Order ID Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/icons/box_icon.png',
                              width: 24,
                              height: 24,
                              color: AppColors.primary,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.inventory_2_outlined,
                                      color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    bookingId.isEmpty ? 'TH2154966541A' : bookingId,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.copy,
                                      size: 16, color: Colors.grey),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Row(
                                children: [
                                  Text('รับพัสดุ',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                  SizedBox(width: 8),
                                  Text('ที่ว่าการอำเภอ',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12)),
                                ],
                              ),
                              const Row(
                                children: [
                                  Text('จุดหมาย',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                  SizedBox(width: 8),
                                  Text('วิทยาลัยอาชีวศึกษาชลบุรี',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Big Blue Status Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text('สถานะปัจจุบัน',
                                          style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('กำลังนำส่งพัสดุ',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20)),
                                    const SizedBox(height: 4),
                                    const Text(
                                        'พัสดุของคุณกำลังนำส่งพัสดุ\nคาดว่าจะได้รับภายใน 11.30 น.',
                                        style: TextStyle(
                                            color: AppColors.primary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Image.asset(
                                  'assets/images/icons/box_icon.png',
                                  width: 80,
                                  height: 80,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.local_shipping,
                                          size: 80, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Progress line on blue card
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.vertical(bottom: Radius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStepWithLabel(
                                  'รับออเดอร์', Icons.inventory_2_outlined, true),
                              _buildProgressLine(true),
                              _buildStepWithLabel(
                                  'รับพัสดุแล้ว', Icons.inventory_2, true),
                              _buildProgressLine(true),
                              _buildStepWithLabel(
                                  'ออกจากต้นทาง', Icons.motorcycle, true),
                              _buildProgressLine(true),
                              _buildStepWithLabel(
                                  'กำลังนำส่ง', Icons.local_shipping, true),
                              _buildProgressLine(false),
                              _buildStepWithLabel('เสร็จสิ้น', Icons.check, false),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Driver Info Card (Pill Shaped)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFF2F4F5),
                          child: Icon(Icons.person, color: Colors.grey, size: 30),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Row(
                                children: [
                                  Text('ทนงทวย ตีหอย',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 14)),
                                  SizedBox(width: 4),
                                  Icon(Icons.star, color: Colors.amber, size: 14),
                                  Text('4.8',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                              const Text('พนักงานขนส่ง',
                                  style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('กษ 1569 · Isuzu D-max',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 10)),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => context.push('${AppRoutes.call}/driver_123'),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.textPrimary),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.phone, size: 18),
                                    Text('โทรหา', style: TextStyle(fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => context.push('${AppRoutes.chat}/driver_123'),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.textPrimary),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.chat_bubble, size: 18),
                                    Text('แชท', style: TextStyle(fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Timeline
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ความคืบหน้าการจัดส่ง',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        _buildTimelineItem('ร้านค้าสร้างออเดอร์',
                            '10 มิ.ย 2569 10.17 น.', true, false),
                        _buildTimelineItem('คนขับเข้ารับพัสดุเรียบร้อย',
                            '10 มิ.ย 2569 10.24 น.', false, false,
                            isActivePoint: true),
                        _buildTimelineItem('พัสดุออกจากต้นทาง',
                            '10 มิ.ย 2569 10.37 น.', false, false,
                            isActivePoint: true),
                        _buildTimelineItem('กำลังนำส่งพัสดุ',
                            '10 มิ.ย 2569 10.40 น.', false, false,
                            isActivePoint: true),
                        _buildTimelineItem('ส่งพัสดุเสร็จสิ้น',
                            'คาดว่าจะได้รับ 10.55 น.', false, true,
                            isActivePoint: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Package Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ข้อมูลพัสดุ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: _buildInfoItem(Icons.inventory_2_outlined,
                                    'คาดว่าจะได้รับ\nพัสดุปกติทั่วไป')),
                            Container(width: 1, height: 40, color: Colors.grey[300]),
                            Expanded(
                                child: _buildInfoItem(Icons.aspect_ratio,
                                    'ขนาด / น้ำหนัก\n20 x 15 x 10 ซม.\n1.2 กก.')),
                            Container(width: 1, height: 40, color: Colors.grey[300]),
                            Expanded(
                                child: _buildInfoItem(Icons.monetization_on_outlined,
                                    'ค่าจัดส่ง\n฿45')),
                            Container(width: 1, height: 40, color: Colors.grey[300]),
                            Expanded(
                                child: _buildInfoItem(Icons.payment,
                                    'วิธีการชำระเงิน\nชำระเงินปลายทาง')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. Address
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ที่อยู่จัดส่ง',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('ผู้รับ',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                  const Text('คุณวิสาขะ บูชา',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  const Text('099-567-2345',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  const Text('ที่อยู่',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                  const Text(
                                    'บ้านเลขที่ 123/345 หมู่ 9\nซ.สว่างมาก ถ.มีออรีน แขวง\nบางละมาด เขต ม.มปวง\nศรีมัณฑะเลกด 10889',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 100, color: Colors.grey[300]),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('หมายเหตุถึงผู้ขนส่ง',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  const Text('ฝากไว้หน้าประตูได้เลยค่ะ\nขอบคุณค่ะ',
                                      style: TextStyle(fontSize: 12)),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          context.push(AppRoutes.cancelOrder),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                      ),
                                      child: const Text('ขอยกเลิกงาน',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // 7. Bottom Help
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('ต้องการความช่วยเหลือ?',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      Text('เราพร้อมช่วยเหลือคุณตลอด 24 ชั่วโมง',
                          style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble, size: 14),
                  label: const Text('ติดต่อแชท', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone, size: 14),
                  label: const Text('โทรหาศูนย์ช่วยเหลือ',
                      style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A4AE3), // Purple color
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepWithLabel(String label, IconData icon, bool isCompleted) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppColors.primary : Colors.grey[300],
          ),
          child: Icon(icon,
              size: 14, color: isCompleted ? Colors.white : Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: isCompleted ? AppColors.textPrimary : Colors.grey,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Widget _buildProgressLine(bool isCompleted) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        height: 2,
        color: isCompleted ? AppColors.primary : Colors.grey[300],
      ),
    );
  }

  Widget _buildTimelineItem(
      String title, String subtitle, bool isCompleted, bool isLast,
      {bool isActivePoint = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.primary
                    : (isActivePoint
                        ? AppColors.primary.withOpacity(0.3)
                        : Colors.grey[300]),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : (isActivePoint
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white),
                          ),
                        )
                      : null),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (isCompleted || isActivePoint)
                        ? AppColors.textPrimary
                        : Colors.grey,
                  )),
              Text(subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              if (!isLast) const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.textPrimary),
        const SizedBox(height: 4),
        Text(text,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
      ],
    );
  }
}
