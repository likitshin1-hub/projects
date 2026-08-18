import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_models.dart';
import '../services/admin_service.dart';

final adminServiceProvider = Provider<AdminService>((ref) => AdminService());

// Active Tab Notifier
class AdminActiveTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

final adminActiveTabProvider = NotifierProvider<AdminActiveTabNotifier, int>(AdminActiveTabNotifier.new);

// Navigation State for Hierarchical Menu
class AdminNavState {
  final String mainTab;
  final String subTab;

  const AdminNavState({this.mainTab = 'dashboard', this.subTab = ''});

  AdminNavState copyWith({String? mainTab, String? subTab}) {
    return AdminNavState(
      mainTab: mainTab ?? this.mainTab,
      subTab: subTab ?? this.subTab,
    );
  }
}

class AdminNavNotifier extends Notifier<AdminNavState> {
  @override
  AdminNavState build() => const AdminNavState(mainTab: 'dashboard', subTab: '');

  void setNav(String mainTab, [String subTab = '']) {
    state = AdminNavState(mainTab: mainTab, subTab: subTab);
  }
}

final adminNavProvider = NotifierProvider<AdminNavNotifier, AdminNavState>(AdminNavNotifier.new);

// Search Query Notifier
class AdminSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final adminSearchQueryProvider = NotifierProvider<AdminSearchQueryNotifier, String>(AdminSearchQueryNotifier.new);

// Customers Notifier
class AdminCustomersNotifier extends Notifier<AsyncValue<List<CustomerModel>>> {
  @override
  AsyncValue<List<CustomerModel>> build() {
    return AsyncValue.data(ref.read(adminServiceProvider).getCustomersSync());
  }

  Future<void> loadCustomers() async {
    try {
      final res = await ref.read(adminServiceProvider).getCustomers();
      state = AsyncValue.data(res);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCustomer(String id, String name, String email, String phone) async {
    await ref.read(adminServiceProvider).updateCustomerInfo(id, name, email, phone);
    await loadCustomers();
  }

  Future<void> toggleSuspend(String id) async {
    await ref.read(adminServiceProvider).toggleCustomerStatus(id);
    await loadCustomers();
  }
}

final adminCustomersProvider = NotifierProvider<AdminCustomersNotifier, AsyncValue<List<CustomerModel>>>(AdminCustomersNotifier.new);

// Drivers Notifier
class AdminDriversNotifier extends Notifier<AsyncValue<List<DriverAdminModel>>> {
  @override
  AsyncValue<List<DriverAdminModel>> build() {
    return AsyncValue.data(ref.read(adminServiceProvider).getDriversSync());
  }

  Future<void> loadDrivers() async {
    try {
      final res = await ref.read(adminServiceProvider).getDrivers();
      state = AsyncValue.data(res);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> approveDriver(String id) async {
    await ref.read(adminServiceProvider).approveDriver(id);
    await loadDrivers();
  }

  Future<void> rejectDriver(String id, String reason) async {
    await ref.read(adminServiceProvider).rejectDriver(id, reason);
    await loadDrivers();
  }

  Future<void> toggleSuspend(String id) async {
    await ref.read(adminServiceProvider).toggleDriverSuspend(id);
    await loadDrivers();
  }
}

final adminDriversProvider = NotifierProvider<AdminDriversNotifier, AsyncValue<List<DriverAdminModel>>>(AdminDriversNotifier.new);

// Admins Notifier
class AdminUsersNotifier extends Notifier<AsyncValue<List<AdminUserModel>>> {
  @override
  AsyncValue<List<AdminUserModel>> build() {
    return AsyncValue.data(ref.read(adminServiceProvider).getAdminsSync());
  }

  Future<void> loadAdmins() async {
    try {
      final res = await ref.read(adminServiceProvider).getAdmins();
      state = AsyncValue.data(res);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAdmin(String id, String name, String email, AdminRole role) async {
    await ref.read(adminServiceProvider).updateAdminUser(id, name, email, role);
    await loadAdmins();
  }

  Future<void> toggleSuspend(String id) async {
    await ref.read(adminServiceProvider).toggleAdminStatus(id);
    await loadAdmins();
  }

  Future<void> addAdmin(String name, String email, AdminRole role) async {
    await ref.read(adminServiceProvider).addAdminUser(name, email, role);
    await loadAdmins();
  }
}

final adminUsersProvider = NotifierProvider<AdminUsersNotifier, AsyncValue<List<AdminUserModel>>>(AdminUsersNotifier.new);

// Orders Notifier
class AdminOrdersNotifier extends Notifier<AsyncValue<List<AdminOrderModel>>> {
  @override
  AsyncValue<List<AdminOrderModel>> build() {
    return AsyncValue.data(ref.read(adminServiceProvider).getOrdersSync());
  }

  Future<void> loadOrders() async {
    try {
      final res = await ref.read(adminServiceProvider).getOrders();
      state = AsyncValue.data(res);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(String orderNo, AdminOrderStatus newStatus, {String? reason, String? cancelledBy}) async {
    await ref.read(adminServiceProvider).updateOrderStatus(orderNo, newStatus, reason: reason, cancelledBy: cancelledBy);
    await loadOrders();
  }
}

final adminOrdersProvider = NotifierProvider<AdminOrdersNotifier, AsyncValue<List<AdminOrderModel>>>(AdminOrdersNotifier.new);

// Selected Order for Live Tracking Focus
class SelectedTrackingOrderNotifier extends Notifier<AdminOrderModel?> {
  @override
  AdminOrderModel? build() => null;

  void selectOrder(AdminOrderModel? order) => state = order;
}

final selectedTrackingOrderProvider = NotifierProvider<SelectedTrackingOrderNotifier, AdminOrderModel?>(SelectedTrackingOrderNotifier.new);

// Vehicle Configs Provider
final vehicleConfigsProvider = FutureProvider<List<VehicleTypeConfig>>((ref) async {
  return ref.watch(adminServiceProvider).getVehicleConfigs();
});

// Real-Time Sync Stream Providers
final realtimeAdminOrdersStreamProvider = StreamProvider<List<AdminOrderModel>>((ref) {
  return ref.watch(adminServiceProvider).ordersStream;
});

final realtimeDriversStreamProvider = StreamProvider<List<DriverAdminModel>>((ref) {
  return ref.watch(adminServiceProvider).driversStream;
});
