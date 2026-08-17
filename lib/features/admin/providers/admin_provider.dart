import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';

class AdminState {
  final AdminDashboardStats? stats;
  final List<PendingDriverApplication> pendingDrivers;
  final List<AdminOrderModel> allOrders;
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;

  const AdminState({
    this.stats,
    this.pendingDrivers = const [],
    this.allOrders = const [],
    this.isLoading = false,
    this.successMessage,
    this.errorMessage,
  });

  AdminState copyWith({
    AdminDashboardStats? stats,
    List<PendingDriverApplication>? pendingDrivers,
    List<AdminOrderModel>? allOrders,
    bool? isLoading,
    String? successMessage,
    String? errorMessage,
  }) {
    return AdminState(
      stats: stats ?? this.stats,
      pendingDrivers: pendingDrivers ?? this.pendingDrivers,
      allOrders: allOrders ?? this.allOrders,
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AdminNotifier extends Notifier<AdminState> {
  final AdminService _adminService = AdminService();

  @override
  AdminState build() {
    _loadInitialAdminData();
    return const AdminState(isLoading: true);
  }

  Future<void> _loadInitialAdminData() async {
    final stats = await _adminService.getDashboardStats();
    final drivers = await _adminService.getPendingDrivers();
    final orders = await _adminService.getAllOrders();

    state = state.copyWith(
      stats: stats,
      pendingDrivers: drivers,
      allOrders: orders,
      isLoading: false,
    );
  }

  Future<bool> approveDriver(String driverId) async {
    state = state.copyWith(isLoading: true);
    final success = await _adminService.approveDriver(driverId);
    if (success) {
      final updatedDrivers = state.pendingDrivers.where((d) => d.id != driverId).toList();
      final currentStats = state.stats;
      AdminDashboardStats? updatedStats;
      if (currentStats != null) {
        updatedStats = AdminDashboardStats(
          totalOrdersToday: currentStats.totalOrdersToday,
          totalRevenueToday: currentStats.totalRevenueToday,
          activeDriversOnline: currentStats.activeDriversOnline + 1,
          pendingDriverApplications: (currentStats.pendingDriverApplications - 1).clamp(0, 999),
        );
      }

      state = state.copyWith(
        isLoading: false,
        pendingDrivers: updatedDrivers,
        stats: updatedStats,
        successMessage: 'อนุมัติใบสมัครคนขับ ID $driverId เรียบร้อยแล้ว!',
      );
      return true;
    }
    state = state.copyWith(isLoading: false, errorMessage: 'ไม่สามารถอนุมัติได้');
    return false;
  }

  Future<bool> rejectDriver(String driverId, String reason) async {
    state = state.copyWith(isLoading: true);
    final success = await _adminService.rejectDriver(driverId, reason);
    if (success) {
      final updatedDrivers = state.pendingDrivers.where((d) => d.id != driverId).toList();
      final currentStats = state.stats;
      AdminDashboardStats? updatedStats;
      if (currentStats != null) {
        updatedStats = AdminDashboardStats(
          totalOrdersToday: currentStats.totalOrdersToday,
          totalRevenueToday: currentStats.totalRevenueToday,
          activeDriversOnline: currentStats.activeDriversOnline,
          pendingDriverApplications: (currentStats.pendingDriverApplications - 1).clamp(0, 999),
        );
      }

      state = state.copyWith(
        isLoading: false,
        pendingDrivers: updatedDrivers,
        stats: updatedStats,
        successMessage: 'ปฏิเสธใบสมัครคนขับ ID $driverId แล้ว',
      );
      return true;
    }
    state = state.copyWith(isLoading: false, errorMessage: 'เกิดข้อผิดพลาด');
    return false;
  }

  void refreshData() {
    _loadInitialAdminData();
  }
}

final adminProvider = NotifierProvider<AdminNotifier, AdminState>(() {
  return AdminNotifier();
});
