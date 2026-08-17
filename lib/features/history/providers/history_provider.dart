import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HistoryStatus { inProgress, completed, cancelled }

class HistoryItemModel {
  final String orderNo;
  final String pickupAddress;
  final String destinationAddress;
  final String route;
  final String dateTime;
  final String price;
  final HistoryStatus status;
  final String vehicle;
  final String vehicleName;
  final String statusText;
  final String driverName;
  final String driverPhone;

  HistoryItemModel({
    required this.orderNo,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.route,
    required this.dateTime,
    required this.price,
    required this.status,
    required this.vehicle,
    required this.vehicleName,
    required this.statusText,
    required this.driverName,
    required this.driverPhone,
  });

  HistoryItemModel copyWith({
    String? orderNo,
    String? pickupAddress,
    String? destinationAddress,
    String? route,
    String? dateTime,
    String? price,
    HistoryStatus? status,
    String? vehicle,
    String? vehicleName,
    String? statusText,
    String? driverName,
    String? driverPhone,
  }) {
    return HistoryItemModel(
      orderNo: orderNo ?? this.orderNo,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      route: route ?? this.route,
      dateTime: dateTime ?? this.dateTime,
      price: price ?? this.price,
      status: status ?? this.status,
      vehicle: vehicle ?? this.vehicle,
      vehicleName: vehicleName ?? this.vehicleName,
      statusText: statusText ?? this.statusText,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
    );
  }
}

class HistoryNotifier extends Notifier<List<HistoryItemModel>> {
  @override
  List<HistoryItemModel> build() {
    return [];
  }

  void addOrUpdateOrder(HistoryItemModel order) {
    final index = state.indexWhere((element) => element.orderNo == order.orderNo);
    if (index != -1) {
      final updated = List<HistoryItemModel>.from(state);
      updated[index] = order;
      state = updated;
    } else {
      state = [order, ...state];
    }
  }

  void markCompleted(String orderNo) {
    final index = state.indexWhere((element) => element.orderNo == orderNo);
    if (index != -1) {
      final updated = List<HistoryItemModel>.from(state);
      updated[index] = updated[index].copyWith(
        status: HistoryStatus.completed,
        statusText: 'จัดส่งสำเร็จ (ผู้รับเซ็นชื่อเรียบร้อย)',
        dateTime: 'เมื่อสักครู่ (จัดส่งสำเร็จ)',
      );
      state = updated;
    }
  }

  void clearAll() {
    state = [];
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<HistoryItemModel>>(() {
  return HistoryNotifier();
});
