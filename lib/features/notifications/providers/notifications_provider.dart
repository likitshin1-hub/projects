import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/user_repository.dart';

class NotificationsNotifier extends Notifier<List<AppNotificationModel>> {
  @override
  List<AppNotificationModel> build() {
    return [
      AppNotificationModel(
        id: 1,
        title: 'คุณได้รับคูปองส่วนลดพิเศษ 50 บาท!',
        message: 'กดใช้คูปองส่วนลดได้ทันทีเมื่อใช้บริการส่งของข้ามจังหวัด',
        timeText: '2 ชั่วโมงที่แล้ว',
        type: 'promo',
        isRead: false,
      ),
    ];
  }

  void addNotification({
    required String title,
    required String message,
    required String type,
  }) {
    // Check if a notification with identical title already exists
    final existingIndex = state.indexWhere((n) => n.title == title);
    if (existingIndex != -1) {
      final updatedList = List<AppNotificationModel>.from(state);
      updatedList[existingIndex] = AppNotificationModel(
        id: updatedList[existingIndex].id,
        title: title,
        message: message,
        timeText: 'เมื่อสักครู่',
        type: type,
        isRead: false,
      );
      state = updatedList;
      return;
    }

    final newNotif = AppNotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      message: message,
      timeText: 'เมื่อสักครู่',
      type: type,
      isRead: false,
    );
    // Add to top of the list
    state = [newNotif, ...state];
  }

  void markAsRead(int id) {
    state = state
        .map((n) => n.id == id
            ? AppNotificationModel(
                id: n.id,
                title: n.title,
                message: n.message,
                timeText: n.timeText,
                type: n.type,
                isRead: true,
              )
            : n)
        .toList();
  }

  void markAllAsRead() {
    state = state
        .map((n) => AppNotificationModel(
              id: n.id,
              title: n.title,
              message: n.message,
              timeText: n.timeText,
              type: n.type,
              isRead: true,
            ))
        .toList();
  }

  void removeNotification(int id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotificationModel>>(
  NotificationsNotifier.new,
);
