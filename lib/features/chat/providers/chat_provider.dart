import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/chat_service.dart';

class ChatState {
  final List<ChatMessageModel> messages;
  final bool isLoading;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
  });

  ChatState copyWith({
    List<ChatMessageModel>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  final ChatService _chatService = ChatService();

  @override
  ChatState build() {
    final now = DateTime.now();
    return ChatState(
      messages: [
        ChatMessageModel(
          id: '1',
          text: 'สวัสดีค่ะ 👋 ยินดีให้บริการค่ะ คุณต้องการให้เราช่วยเรื่องใดคะ ?',
          sender: 'bot',
          timestamp: now.subtract(const Duration(minutes: 15)),
          timeText: '10:30',
        ),
        ChatMessageModel(
          id: '2',
          text: 'สวัสดีครับ พัสดุกำลังจัดส่งนะครับ ให้ช่วยอะไรบอกได้เลยครับ 🛵',
          sender: 'driver',
          timestamp: now.subtract(const Duration(minutes: 12)),
          timeText: '10:32',
        ),
      ],
    );
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final now = DateTime.now();
    final String timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final userMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: 'user',
      timestamp: now,
      timeText: timeStr,
    );

    state = state.copyWith(messages: [...state.messages, userMsg]);

    _chatService.sendMessage(driverId: 'driver_somchai', text: text);

    // Auto driver response simulation
    _triggerDriverReply(text);
  }

  void sendImageMessage(Uint8List imageBytes, {String caption = 'ส่งรูปภาพแล้ว'}) {
    final now = DateTime.now();
    final String timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final imageMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: caption,
      sender: 'user',
      messageType: ChatMessageType.image,
      imageBytes: imageBytes,
      timestamp: now,
      timeText: timeStr,
    );

    state = state.copyWith(messages: [...state.messages, imageMsg]);

    _chatService.sendMessage(
      driverId: 'driver_somchai',
      text: caption,
      type: ChatMessageType.image,
      imageBytes: imageBytes,
    );

    _triggerDriverReply('รูปภาพ');
  }

  void sendLocationMessage(LatLng location, {String locationName = 'พิกัดปัจจุบันของฉัน'}) {
    final now = DateTime.now();
    final String timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final locMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: locationName,
      sender: 'user',
      messageType: ChatMessageType.location,
      location: location,
      locationName: locationName,
      timestamp: now,
      timeText: timeStr,
    );

    state = state.copyWith(messages: [...state.messages, locMsg]);

    _chatService.sendMessage(
      driverId: 'driver_somchai',
      text: locationName,
      type: ChatMessageType.location,
      location: location,
    );

    _triggerDriverReply('พิกัด');
  }

  void _triggerDriverReply(String userText) {
    Timer(const Duration(milliseconds: 1400), () {
      String replyText = 'รับทราบครับผม! เดี๋ยวรีบขับรถนำส่งให้ถึงจุดหมายอย่างปลอดภัยครับ 🛵';
      final lower = userText.toLowerCase();

      if (lower.contains('รูปภาพ') || lower.contains('รูป')) {
        replyText = 'ได้รับรูปภาพเรียบร้อยแล้วครับ ขอบคุณครับ! 📸';
      } else if (lower.contains('พิกัด') || lower.contains('ตำแหน่ง') || lower.contains('หมุด')) {
        replyText = 'ได้รับพิกัดสถานที่แล้วครับ เดี๋ยวผมปักหมุดขับตรงไปหาตามตำแหน่งนี้เลยครับ 📍';
      } else if (lower.contains('ตรงไหน') || lower.contains('ไหน') || lower.contains('ถึงไหน')) {
        replyText = 'ตอนนี้ผมอยู่ห่างออกไปราว ๆ 1.5 กิโลเมตรครับ ขับขี่มาถึงแถวแยกถนนหลักแล้วครับ ใกล้ถึงแล้วครับ! 🛣️';
      } else if (lower.contains('ขอบคุณ') || lower.contains('thx') || lower.contains('thanks')) {
        replyText = 'ด้วยความยินดีครับคุณลูกค้า เดินทางปลอดภัยและขอบคุณที่เลือกใช้บริการของเรานะครับ 😊';
      } else if (lower.contains('ฝาก') || lower.contains('ป้อมยาม')) {
        replyText = 'รับทราบครับ เดี๋ยวเมื่อถึงจุดหมายแล้วผมจะฝากไว้ที่ป้อมยามพร้อมถ่ายรูปยืนยันให้นะครับ!';
      }

      final replyNow = DateTime.now();
      final String replyTimeStr = '${replyNow.hour.toString().padLeft(2, '0')}:${replyNow.minute.toString().padLeft(2, '0')}';

      final driverMsg = ChatMessageModel(
        id: replyNow.millisecondsSinceEpoch.toString(),
        text: replyText,
        sender: 'driver',
        timestamp: replyNow,
        timeText: replyTimeStr,
      );

      state = state.copyWith(messages: [...state.messages, driverMsg]);
    });
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});
