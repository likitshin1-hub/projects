import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/booking_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String? initialVehicleType;

  const BookingScreen({super.key, this.initialVehicleType});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _detailsController = TextEditingController();

  final List<String> _vehicleOptions = ['มอเตอร์ไซค์', 'รถกระบะ', 'รถบรรทุก'];
  late String _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.initialVehicleType ?? _vehicleOptions.first;
    
    // ตั้งค่าเริ่มต้นลง State
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingProvider.notifier).updateForm(
            vehicleType: _selectedVehicle,
          );
    });

    _pickupController.addListener(_onFormChanged);
    _dropoffController.addListener(_onFormChanged);
    _detailsController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    ref.read(bookingProvider.notifier).updateForm(
          pickup: _pickupController.text,
          dropoff: _dropoffController.text,
          details: _detailsController.text,
        );
  }

  void _onVehicleChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedVehicle = newValue;
      });
      ref.read(bookingProvider.notifier).updateForm(
            vehicleType: _selectedVehicle,
          );
    }
  }

  Future<void> _submit() async {
    final success = await ref.read(bookingProvider.notifier).submitBooking();
    if (success && mounted) {
      // Go to tracking screen
      final bId = ref.read(bookingProvider).bookingId;
      context.pushReplacement('${AppRoutes.tracking}/$bId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);

    // Show error via SnackBar if any
    ref.listen<BookingState>(bookingProvider, (previous, next) {
      if (next.status == BookingStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('จองรถส่งพัสดุ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== Vehicle Type Selection =====
            Text(
              'ประเภทยานพาหนะ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.sm),
            DropdownButtonFormField<String>(
              value: _selectedVehicle,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.sm,
                ),
              ),
              items: _vehicleOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: _onVehicleChanged,
            ),
            const SizedBox(height: AppDimensions.lg),

            // ===== Location =====
            Text(
              'สถานที่',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.sm),
            CustomTextField(
              label: 'จุดรับพัสดุ',
              hintText: 'กรอกที่อยู่จุดรับ หรือชื่อสถานที่',
            ),
            // Override controller after init since CustomTextField is simple wrapper (Normally we'd pass controller, we need to update CustomTextField to accept controller)
            TextField(
              controller: _pickupController,
              decoration: InputDecoration(
                labelText: 'จุดรับพัสดุ',
                hintText: 'กรอกที่อยู่จุดรับ หรือชื่อสถานที่',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                prefixIcon: const Icon(Icons.my_location, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            TextField(
              controller: _dropoffController,
              decoration: InputDecoration(
                labelText: 'จุดส่งพัสดุ',
                hintText: 'กรอกที่อยู่จุดส่ง หรือชื่อสถานที่',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                prefixIcon: const Icon(Icons.location_on, color: AppColors.error),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // ===== Details =====
            Text(
              'รายละเอียดพัสดุ / หมายเหตุ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.sm),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'เช่น ระวังแตก, ต้องการคนช่วยยก 1 คน',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.xxl),

            // ===== Price Display =====
            Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ราคาประเมิน:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  bookingState.status == BookingStatus.calculating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          bookingState.estimatedPrice > 0
                              ? '฿ ${bookingState.estimatedPrice.toStringAsFixed(2)}'
                              : '฿ -',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.xl),

            // ===== Submit Button =====
            ElevatedButton(
              onPressed: (bookingState.status == BookingStatus.ready &&
                      bookingState.estimatedPrice > 0)
                  ? _submit
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppDimensions.md),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              child: bookingState.status == BookingStatus.submitting
                  ? const CircularProgressIndicator(color: AppColors.white)
                  : const Text(
                      'ยืนยันการจอง',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }
}
