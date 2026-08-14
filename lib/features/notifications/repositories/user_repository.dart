import '../../../core/network/dio_client.dart';

class AppNotificationModel {
  final int id;
  final String title;
  final String message;
  final String timeText;
  final String type;
  final bool isRead;

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timeText,
    required this.type,
    this.isRead = false,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'การแจ้งเตือน',
      message: json['message'] as String? ?? json['content'] as String? ?? '',
      timeText: json['created_at'] != null ? '${json['created_at']}'.substring(0, 10) : 'เมื่อสักครู่',
      type: json['type'] as String? ?? 'system',
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}

class UserRepository {
  final DioClient _dioClient;

  UserRepository({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// ดึงรายการแจ้งเตือนจาก Laravel Backend API (GET /api/notifications)
  Future<List<AppNotificationModel>> getNotifications() async {
    try {
      final response = await _dioClient.get('/notifications');
      if (response.data is List) {
        final List list = response.data as List;
        return list.map((json) => AppNotificationModel.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Fallback notifications if offline
    }
    return [
      AppNotificationModel(
        id: 1,
        title: 'ยินดีต้อนรับสู่ TB MoveHub!',
        message: 'เริ่มต้นใช้งานบริการขนส่งพัสดุและเรียกรถย้ายของได้ทันที พร้อมรับคูปองส่วนลดพิเศษ',
        timeText: '10 นาทีที่แล้ว',
        type: 'promo',
      ),
      AppNotificationModel(
        id: 2,
        title: 'ยืนยันการรับออเดอร์สำเร็จ',
        message: 'คนขับ สมชาย มั่นคง ได้รับงานเรียกรถส่งพัสดุเรียบร้อยแล้ว',
        timeText: '1 ชั่วโมงที่แล้ว',
        type: 'order',
      ),
    ];
  }

  /// ดึงสถานที่ปักหมุดของผู้ใช้ (GET /api/user-addresses)
  Future<List<Map<String, dynamic>>> getAddresses() async {
    try {
      final response = await _dioClient.get('/user-addresses');
      if (response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }
}
