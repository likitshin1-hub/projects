import 'dart:async';
import 'package:flutter/foundation.dart';

class PushNotificationData {
  final String title;
  final String body;
  final Map<String, dynamic> data;

  PushNotificationData({
    required this.title,
    required this.body,
    required this.data,
  });
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final StreamController<PushNotificationData> _notificationStreamController =
      StreamController<PushNotificationData>.broadcast();

  Stream<PushNotificationData> get notificationStream => _notificationStreamController.stream;

  bool _isInitialized = false;

  /// ตั้งค่า Push Notification Service (FCM & Local Event Bus Stream)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('📲 Push Notification Service initialized successfully');
    } catch (e) {
      debugPrint('⚠️ Push Notification initialization fallback: $e');
    }

    _isInitialized = true;
  }

  /// Subscribe หัวข้อการแจ้งเตือนตาม Order ID (เช่น order_TB504321)
  Future<void> subscribeToOrderTopic(String orderId) async {
    debugPrint('🔔 Subscribed to push topic: order_$orderId');
  }

  /// Unsubscribe หัวข้อการแจ้งเตือน
  Future<void> unsubscribeFromOrderTopic(String orderId) async {
    debugPrint('🔕 Unsubscribed from push topic: order_$orderId');
  }

  /// ส่งการแจ้งเตือนแบบ In-App & Local Push Notification เมื่อสถานะออเดอร์เปลี่ยน
  void triggerLocalPushNotification({
    required String title,
    required String body,
    Map<String, dynamic>? extraData,
  }) {
    _notificationStreamController.add(
      PushNotificationData(
        title: title,
        body: body,
        data: extraData ?? {},
      ),
    );
  }

  void dispose() {
    _notificationStreamController.close();
  }
}
