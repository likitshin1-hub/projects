import 'dart:async';
import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/network/dio_client.dart';

enum ChatMessageType { text, image, location }

class ChatMessageModel {
  final String id;
  final String text;
  final String sender; // 'user', 'driver', 'bot'
  final ChatMessageType messageType;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final LatLng? location;
  final String? locationName;
  final DateTime timestamp;
  final String timeText;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.sender,
    this.messageType = ChatMessageType.text,
    this.imageBytes,
    this.imageUrl,
    this.location,
    this.locationName,
    required this.timestamp,
    required this.timeText,
  });
}

class ChatService {
  final DioClient _dioClient;

  ChatService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// ดึงรายการข้อความย้อนหลัง (GET /api/chat/messages/{driverId})
  Future<List<ChatMessageModel>> getMessages(String driverId) async {
    try {
      final response = await _dioClient.get('/chat/messages/$driverId');
      if (response.statusCode == 200 && response.data != null) {
        // Backend messages parsing if available
      }
    } catch (e) {
      // Fallback
    }

    final now = DateTime.now();
    return [
      ChatMessageModel(
        id: '1',
        text: 'สวัสดีค่ะ 👋 ยินดีให้บริการค่ะ คุณต้องการให้เราช่วยเรื่องใดคะ ?',
        sender: 'bot',
        timestamp: now.subtract(const Duration(minutes: 15)),
        timeText: '10:30',
      ),
    ];
  }

  /// ส่งข้อความไปยัง Backend (POST /api/chat/send)
  Future<bool> sendMessage({
    required String driverId,
    required String text,
    ChatMessageType type = ChatMessageType.text,
    Uint8List? imageBytes,
    LatLng? location,
  }) async {
    try {
      final response = await _dioClient.post(
        '/chat/send',
        data: {
          'driver_id': driverId,
          'message': text,
          'type': type.name,
          if (location != null) 'lat': location.latitude,
          if (location != null) 'lng': location.longitude,
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      // Fallback
    }
    return true;
  }
}
