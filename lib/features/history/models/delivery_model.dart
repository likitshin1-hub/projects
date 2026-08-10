enum DeliveryStatus {
  inProgress, // กำลังดำเนินการ
  completed,  // เสร็จสิ้น
  cancelled,  // ยกเลิก
}

class DeliveryModel {
  final String id;
  final String orderNo;
  final String pickup;
  final String destination;
  final String date;
  final String time;
  final double price;
  final DeliveryStatus status;
  final bool isHistoryOnly;

  const DeliveryModel({
    required this.id,
    required this.orderNo,
    required this.pickup,
    required this.destination,
    required this.date,
    required this.time,
    required this.price,
    required this.status,
    this.isHistoryOnly = false,
  });

  String get statusText {
    switch (status) {
      case DeliveryStatus.inProgress:
        return 'กำลังดำเนินการ';
      case DeliveryStatus.completed:
        return 'เสร็จสิ้น';
      case DeliveryStatus.cancelled:
        return 'ยกเลิก';
    }
  }
}
