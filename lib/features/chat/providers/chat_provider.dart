import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/chat_service.dart';

class ChatState {
  final Map<String, List<ChatMessageModel>> conversations;
  final bool isLoading;
  final bool isTyping;

  const ChatState({
    this.conversations = const {},
    this.isLoading = false,
    this.isTyping = false,
  });

  List<ChatMessageModel> getMessagesFor(String driverId) {
    if (conversations.containsKey(driverId)) {
      return conversations[driverId]!;
    }
    final isSupport = driverId == 'call_center' || driverId == 'support' || driverId == 'center';
    final now = DateTime.now();
    return [
      if (isSupport)
        ChatMessageModel(
          id: '1',
          text: 'สวัสดีค่ะ 👋 ยินดีให้บริการค่ะ คุณต้องการให้เราช่วยเรื่องใดคะ ?',
          sender: 'bot',
          timestamp: now.subtract(const Duration(minutes: 15)),
          timeText: '10:30',
        )
      else
        ChatMessageModel(
          id: '1',
          text: 'กำลังไปยังจุดรับพัสดุครับ',
          sender: 'driver',
          timestamp: now.subtract(const Duration(minutes: 12)),
          timeText: '09:15',
        )
    ];
  }

  ChatState copyWith({
    Map<String, List<ChatMessageModel>>? conversations,
    bool? isLoading,
    bool? isTyping,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  final ChatService _chatService = ChatService();

  @override
  ChatState build() {
    return const ChatState();
  }

  void sendMessage(String text, {required String driverId}) {
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

    final currentMessages = state.getMessagesFor(driverId);
    final updatedMap = Map<String, List<ChatMessageModel>>.from(state.conversations);
    updatedMap[driverId] = [...currentMessages, userMsg];

    state = state.copyWith(conversations: updatedMap);

    _chatService.sendMessage(driverId: driverId, text: text);

    _triggerDriverReply(text, driverId: driverId);
  }

  void sendImageMessage(Uint8List imageBytes, {String caption = 'ส่งรูปภาพแล้ว', required String driverId}) {
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

    final currentMessages = state.getMessagesFor(driverId);
    final updatedMap = Map<String, List<ChatMessageModel>>.from(state.conversations);
    updatedMap[driverId] = [...currentMessages, imageMsg];

    state = state.copyWith(conversations: updatedMap);

    _chatService.sendMessage(
      driverId: driverId,
      text: caption,
      type: ChatMessageType.image,
      imageBytes: imageBytes,
    );

    _triggerDriverReply('รูปภาพ', driverId: driverId);
  }

  void sendLocationMessage(LatLng location, {String locationName = 'พิกัดปัจจุบันของฉัน', required String driverId}) {
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

    final currentMessages = state.getMessagesFor(driverId);
    final updatedMap = Map<String, List<ChatMessageModel>>.from(state.conversations);
    updatedMap[driverId] = [...currentMessages, locMsg];

    state = state.copyWith(conversations: updatedMap);

    _chatService.sendMessage(
      driverId: driverId,
      text: locationName,
      type: ChatMessageType.location,
      location: location,
    );

    _triggerDriverReply('พิกัด', driverId: driverId);
  }

  void _triggerDriverReply(String userText, {required String driverId}) {
    // Show real-time typing indicator
    state = state.copyWith(isTyping: true);

    Timer(const Duration(milliseconds: 1200), () {
      final isSupport = driverId == 'call_center' || driverId == 'support' || driverId == 'center';
      String replyText = isSupport
          ? 'รับเรื่องเรียบร้อยแล้วครับ เจ้าหน้าที่กำลังดำเนินการช่วยเหลือให้สักครู่นะครับ ✨'
          : 'รับทราบครับผม! เดี๋ยวรีบขับรถนำส่งให้ถึงจุดหมายอย่างปลอดภัยครับ 🛵';

      final lower = userText.toLowerCase();

      if (isSupport) {
        if (lower.contains('ยกเลิก') || lower.contains('คืนเงิน')) {
          replyText = 'สำหรับการยกเลิกออเดอร์ หรือขอคืนเงิน ระบบกำลังส่งเรื่องให้ฝ่ายการเงินตรวจสอบ จะแจ้งผลกลับภายใน 5 นาทีครับ 💳';
        } else if (lower.contains('ช้า') || lower.contains('ยังไม่ถึง')) {
          replyText = 'ขออภัยในความไม่สะดวกครับ เจ้าหน้าที่เร่งติดตามคนขับในเส้นทางให้เรียบร้อยแล้วครับ 🛵';
        } else if (lower.contains('ขอบคุณ')) {
          replyText = 'ยินดีให้บริการครับ หากต้องการความช่วยเหลือเพิ่มเติม สามารถทักแชทหาศูนย์บริการได้ตลอด 24 ชม. ครับ 🙏';
        }
      } else {
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
      }

      final replyNow = DateTime.now();
      final String replyTimeStr = '${replyNow.hour.toString().padLeft(2, '0')}:${replyNow.minute.toString().padLeft(2, '0')}';

      final driverMsg = ChatMessageModel(
        id: replyNow.millisecondsSinceEpoch.toString(),
        text: replyText,
        sender: isSupport ? 'bot' : 'driver',
        timestamp: replyNow,
        timeText: replyTimeStr,
      );

      final currentMessages = state.getMessagesFor(driverId);
      final updatedMap = Map<String, List<ChatMessageModel>>.from(state.conversations);
      updatedMap[driverId] = [...currentMessages, driverMsg];

      state = state.copyWith(
        conversations: updatedMap,
        isTyping: false,
      );
    });
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});
