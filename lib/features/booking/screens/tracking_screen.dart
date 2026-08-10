import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';

class TrackingScreen extends StatefulWidget {
  final String bookingId;

  const TrackingScreen({super.key, required this.bookingId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final int _currentStep = 2; // "กำลังเดินทาง"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
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
      body: Stack(
        children: [
          // 1. Fake Map Background
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF2F4F5),
              child: Stack(
                children: [
                  // Fake road lines
                  Positioned(
                    top: 100,
                    left: 50,
                    right: 50,
                    bottom: 200,
                    child: CustomPaint(
                      painter: _FakeRoutePainter(),
                    ),
                  ),
                  // Fake destination marker
                  Positioned(
                    top: 80,
                    right: 60,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              )
                            ],
                          ),
                          child: const Text('จุดส่งสินค้า',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const Icon(Icons.location_on,
                            color: Colors.red, size: 36),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Bottom Overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    // Driver Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xFF4285F4),
                            child: Icon(Icons.person,
                                size: 40, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'นาย สมปอง มีดี',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Honda wave 125i สีดำ\nล้อทองขอบ17 ซัก67',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      height: 1.2),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '4.9',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                    const Text(
                                      ' (326 รีวิว)',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Action Buttons
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  context.push('${AppRoutes.chat}/driver_123');
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: AppColors.primary),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.chat_bubble_outline,
                                      color: AppColors.primary, size: 20),
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () {
                                  context.push('${AppRoutes.call}/driver_123');
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: AppColors.primary),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.phone_outlined,
                                      color: AppColors.primary, size: 20),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tracking Status Card
                    GestureDetector(
                      onTap: () {
                        context.push('${AppRoutes.trackingDetail}/${widget.bookingId}');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'คนขับกำลังไปหาคุณ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14),
                                children: [
                                  TextSpan(text: 'คนขับกำลังไป '),
                                  TextSpan(
                                    text: '15 นาที',
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Progress Bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStep(0, Icons.inventory_2_outlined),
                                _buildLine(0),
                                _buildStep(1, Icons.inventory),
                                _buildLine(1),
                                _buildStep(2, Icons.motorcycle),
                                _buildLine(2),
                                _buildStep(3, Icons.local_shipping),
                                _buildLine(3),
                                _buildStep(4, Icons.check),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Order Details Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('รหัสออเดอร์',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(widget.bookingId.isEmpty ? 'B2553' : widget.bookingId,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          const Text('วันที่ / เวลา',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          const Text('18 พ.ค. 67 / 15:20',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          const Text('ระยะ / น้ำหนัก',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          const Text('3.8 กม. / 1.2 กก.',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
      ),
    );
  }

  Widget _buildStep(int stepIndex, IconData icon) {
    bool isCompleted = stepIndex <= _currentStep;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? const Color(0xFFE8F0FE) : Colors.grey[200],
      ),
      child: Icon(
        icon,
        size: 16,
        color: isCompleted ? AppColors.primary : Colors.grey,
      ),
    );
  }

  Widget _buildLine(int stepIndex) {
    bool isCompleted = stepIndex < _currentStep;
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? AppColors.primary : Colors.grey[300],
      ),
    );
  }
}

// Custom Painter to draw a fake route line on the map
class _FakeRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.9);
    path.lineTo(size.width * 0.4, size.height * 0.7);
    path.lineTo(size.width * 0.3, size.height * 0.5);
    path.lineTo(size.width * 0.7, size.height * 0.3);
    path.lineTo(size.width * 0.9, size.height * 0.1);

    canvas.drawPath(path, paint);

    // Draw current location dot
    final dotPaint = Paint()..color = AppColors.primary;
    final dotBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
      
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.9), 8, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.9), 8, dotBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
