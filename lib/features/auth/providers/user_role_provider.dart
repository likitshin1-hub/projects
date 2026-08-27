import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserActiveMode { customer, driver }

class UserActiveModeNotifier extends Notifier<UserActiveMode> {
  @override
  UserActiveMode build() => UserActiveMode.customer;

  void toggleMode() {
    state = state == UserActiveMode.customer ? UserActiveMode.driver : UserActiveMode.customer;
  }

  void setMode(UserActiveMode mode) {
    state = mode;
  }
}

final userActiveModeProvider = NotifierProvider<UserActiveModeNotifier, UserActiveMode>(UserActiveModeNotifier.new);

class DriverApprovalNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setApproved(bool isApproved) {
    state = isApproved;
  }
}

final isDriverApprovedProvider = NotifierProvider<DriverApprovalNotifier, bool>(DriverApprovalNotifier.new);
