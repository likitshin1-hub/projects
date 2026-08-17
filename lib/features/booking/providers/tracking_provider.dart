import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notifications/providers/notifications_provider.dart';
import 'driver_provider.dart';

class TrackingState {
  final int currentStep; // 0=รับออเดอร์, 1=รับพัสดุแล้ว, 2=บนทางด่วน, 3=เสร็จสิ้นแล้ว
  final bool isRunning;
  final bool isCompleted;
  final String orderNo;

  TrackingState({
    this.currentStep = 0,
    this.isRunning = false,
    this.isCompleted = false,
    this.orderNo = 'TB668511',
  });

  TrackingState copyWith({
    int? currentStep,
    bool? isRunning,
    bool? isCompleted,
    String? orderNo,
  }) {
    return TrackingState(
      currentStep: currentStep ?? this.currentStep,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
      orderNo: orderNo ?? this.orderNo,
    );
  }
}

class TrackingNotifier extends Notifier<TrackingState> {
  Timer? _timer;

  @override
  TrackingState build() {
    return TrackingState();
  }

  void startTrackingTimer(dynamic ref) {
    if (state.isRunning) return;

    state = state.copyWith(isRunning: true, currentStep: 0, isCompleted: false);
    _pushNotificationForStep(0, ref);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 12), (timer) {
      if (state.currentStep < 3) {
        final nextStep = state.currentStep + 1;
        final completed = nextStep == 3;
        state = state.copyWith(
          currentStep: nextStep,
          isCompleted: completed,
          isRunning: !completed,
        );

        _pushNotificationForStep(nextStep, ref);

        if (completed) {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void setStep(int step, dynamic ref) {
    final completed = step >= 3;
    state = state.copyWith(
      currentStep: step,
      isCompleted: completed,
      isRunning: !completed,
    );
    _pushNotificationForStep(step, ref);
  }

  void _pushNotificationForStep(int step, dynamic ref) {
    final driver = ref.read(driverProvider);
    final orderNo = state.orderNo;
    String title = '';
    String message = '';

    switch (step) {
      case 0:
        title = 'ออเดอร์ #$orderNo: รับออเดอร์เรียบร้อยแล้ว';
        message = 'คนขับ ${driver.name} (${driver.fullVehicleInfo}) กำลังเดินทางไปรับพัสดุของคุณ';
        break;
      case 1:
        title = 'ออเดอร์ #$orderNo: ไรเดอร์รับพัสดุแล้ว';
        message = 'ไรเดอร์ ${driver.name} รับพัสดุขึ้นรถเรียบร้อยแล้ว กำลังนำส่งปลายทาง';
        break;
      case 2:
        title = 'ออเดอร์ #$orderNo: อยู่ระหว่างการขนส่ง (บนทางด่วน)';
        message = 'พนักงานขับรถ ${driver.name} เดินทางบนเส้นทางจริง (คาดว่าจะถึงใน 15 นาที)';
        break;
      case 3:
        title = 'ออเดอร์ #$orderNo: เสร็จสิ้นแล้ว';
        message = 'จัดส่งสำเร็จ! ผู้รับปลายทางเซ็นรับพัสดุเรียบร้อยแล้ว ขอบคุณที่ใช้บริการ TB MOVE HUB';
        break;
    }

    if (title.isNotEmpty) {
      ref.read(notificationsProvider.notifier).addNotification(
            title: title,
            message: message,
            type: 'order',
          );
    }
  }

  void reset() {
    _timer?.cancel();
    state = TrackingState();
  }
}

final trackingProvider = NotifierProvider<TrackingNotifier, TrackingState>(
  TrackingNotifier.new,
);
