import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';

class TrackingScreen extends StatefulWidget {
  final String bookingId;

  const TrackingScreen({super.key, required this.bookingId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _simulateTracking();
  }

  void _simulateTracking() async {
    // 0: ค้นหาคนขับ
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _currentStep = 1);
    
    // 1: คนขับกำลังไปรับ
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _currentStep = 2);

    // 2: กำลังจัดส่ง
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) setState(() => _currentStep = 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ติดตามสถานะ'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.go(AppRoutes.home);
          },
        ),
      ),
      body: Column(
        children: [
          // ===== Map Placeholder =====
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.background,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 64, color: AppColors.border),
                    SizedBox(height: 8),
                    Text('Google Maps Placeholder', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),

          // ===== Status Detail =====
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.cardRadius)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Booking ID
                  Text(
                    'รหัสการจอง: ${widget.bookingId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.md),

                  // Driver Info (Show only when step > 0)
                  if (_currentStep > 0)
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.person, color: AppColors.white),
                          ),
                          const SizedBox(width: AppDimensions.md),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('สมชาย ขยันขับ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('กท 1234', style: TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.phone, color: AppColors.primary),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(height: AppDimensions.lg),

                  // Timeline Status
                  Expanded(
                    child: ListView(
                      children: [
                        _buildStatusTile(
                          title: 'กำลังค้นหาคนขับ',
                          isActive: _currentStep >= 0,
                          isDone: _currentStep > 0,
                          icon: Icons.search,
                        ),
                        _buildStatusTile(
                          title: 'คนขับกำลังไปรับพัสดุ',
                          isActive: _currentStep >= 1,
                          isDone: _currentStep > 1,
                          icon: Icons.directions_car,
                        ),
                        _buildStatusTile(
                          title: 'กำลังจัดส่ง',
                          isActive: _currentStep >= 2,
                          isDone: _currentStep > 2,
                          icon: Icons.local_shipping,
                        ),
                        _buildStatusTile(
                          title: 'จัดส่งสำเร็จ',
                          isActive: _currentStep >= 3,
                          isDone: _currentStep > 3,
                          icon: Icons.check_circle,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile({
    required String title,
    required bool isActive,
    required bool isDone,
    required IconData icon,
    bool isLast = false,
  }) {
    final color = isActive ? AppColors.primary : AppColors.border;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? AppColors.primary : (isActive ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent),
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(
                isDone ? Icons.check : icon,
                size: 16,
                color: isDone ? AppColors.white : color,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isDone ? AppColors.primary : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
