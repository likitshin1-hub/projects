import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/user_role_provider.dart';

enum DriverShiftStatus {
  working, // 🟢 เข้างาน / พร้อมรับงาน
  breakTime, // ☕ พักงาน / หยุดรับงานชั่วคราว
  clockedOut, // 🔴 ออกงาน / สลับเป็นผู้ใช้ทั่วไป
}

class DriverShiftNotifier extends Notifier<DriverShiftStatus> {
  @override
  DriverShiftStatus build() {
    return DriverShiftStatus.working;
  }

  void clockIn() {
    state = DriverShiftStatus.working;
    ref.read(userActiveModeProvider.notifier).setMode(UserActiveMode.driver);
  }

  void takeBreak() {
    state = DriverShiftStatus.breakTime;
  }

  void resumeWork() {
    state = DriverShiftStatus.working;
  }

  void clockOut() {
    state = DriverShiftStatus.clockedOut;
    ref.read(userActiveModeProvider.notifier).setMode(UserActiveMode.customer);
  }
}

final driverShiftProvider = NotifierProvider<DriverShiftNotifier, DriverShiftStatus>(() {
  return DriverShiftNotifier();
});
