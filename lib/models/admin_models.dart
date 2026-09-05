enum DriverVerificationStatus { pending, approved, rejected, suspended }

enum AdminRole { superAdmin, admin, staff, auditor }

enum AdminOrderStatus {
  pending,
  accepted,
  driverArriving,
  pickedUp,
  inTransit,
  completed,
  cancelled,
}

extension AdminOrderStatusX on AdminOrderStatus {
  String get thaiLabel {
    switch (this) {
      case AdminOrderStatus.pending:
        return 'รอคนขับตอบรับ (Pending)';
      case AdminOrderStatus.accepted:
        return 'คนขับรับงานแล้ว (Accepted)';
      case AdminOrderStatus.driverArriving:
        return 'กำลังไปจุดรับ (Arriving)';
      case AdminOrderStatus.pickedUp:
        return 'รับของแล้ว (Picked Up)';
      case AdminOrderStatus.inTransit:
        return 'กำลังนำส่ง (In Transit)';
      case AdminOrderStatus.completed:
        return 'จัดส่งสำเร็จ (Completed)';
      case AdminOrderStatus.cancelled:
        return 'ยกเลิกคำสั่งซื้อ (Cancelled)';
    }
  }
}

class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final int totalOrders;
  final double totalSpent;
  final double rating;
  bool isSuspended;
  String? suspensionReason;
  DateTime? suspendedAt;
  String? suspensionDuration; // '7 วัน', '30 วัน', 'ถาวร (Permanent)'
  int warningCount;
  List<String> incidentTags;
  final bool isVip;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.totalOrders,
    required this.totalSpent,
    this.rating = 5.0,
    this.isSuspended = false,
    this.suspensionReason,
    this.suspendedAt,
    this.suspensionDuration,
    this.warningCount = 0,
    this.incidentTags = const [],
    this.isVip = false,
    required this.createdAt,
  });
}

class ComplaintTicket {
  final String id;
  final String orderNo;
  final String reporterType; // 'ไรเดอร์ (Driver)' or 'ลูกค้า (Customer)'
  final String reporterName;
  final String reporterPhone;
  final String accusedCustomerId;
  final String accusedCustomerName;
  final String accusedCustomerPhone;
  final String category;
  final String severity; // 'critical', 'high', 'medium', 'low'
  final String description;
  final String evidenceSummary;
  String status; // 'pending', 'investigating', 'action_taken', 'dismissed'
  String? actionTakenNotes;
  final DateTime createdAt;
  DateTime? resolvedAt;

  ComplaintTicket({
    required this.id,
    required this.orderNo,
    required this.reporterType,
    required this.reporterName,
    required this.reporterPhone,
    required this.accusedCustomerId,
    required this.accusedCustomerName,
    required this.accusedCustomerPhone,
    required this.category,
    this.severity = 'high',
    required this.description,
    required this.evidenceSummary,
    this.status = 'pending',
    this.actionTakenNotes,
    required this.createdAt,
    this.resolvedAt,
  });
}


class DriverAdminModel {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String vehicleType;
  final String brand;
  final String model;
  final String plate;
  final String province;
  final String color;
  DriverVerificationStatus status;
  bool isOnline;
  final double rating;
  final int completedJobs;
  final double walletBalance;
  final double totalEarnings;
  final String area;
  final DateTime submittedAt;

  DriverAdminModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.plate,
    this.province = 'กรุงเทพฯ',
    required this.color,
    required this.status,
    required this.isOnline,
    this.rating = 4.9,
    this.completedJobs = 120,
    this.walletBalance = 0.0,
    this.totalEarnings = 0.0,
    this.area = 'สุขุมวิท - คลองเตย',
    required this.submittedAt,
  });
}

class AdminOrderModel {
  final String orderNo;
  final String customerName;
  final String customerPhone;
  final String driverName;
  final String driverPhone;
  final String vehicleType;
  final String parcelType;
  final String paymentMethod;
  final double distanceKm;
  final String pickupAddress;
  final String dropoffAddress;
  final double amount;
  AdminOrderStatus status;
  final DateTime createdAt;

  AdminOrderModel({
    required this.orderNo,
    required this.customerName,
    required this.customerPhone,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleType,
    this.parcelType = 'พัสดุด่วน / เอกสาร',
    this.paymentMethod = 'PromptPay QR',
    this.distanceKm = 8.5,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.amount,
    required this.status,
    required this.createdAt,
  });
}

class AdminUserModel {
  final String id;
  final String name;
  final String email;
  final AdminRole role;
  bool isActive;
  final String department;
  final DateTime lastLogin;

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.department = 'ศูนย์ควบคุมระบบ',
    required this.lastLogin,
  });
}

class AuditLogItem {
  final String id;
  final String adminName;
  final String action;
  final String target;
  final DateTime timestamp;

  AuditLogItem({
    required this.id,
    required this.adminName,
    required this.action,
    required this.target,
    required this.timestamp,
  });
}

class WithdrawalRequest {
  final String id;
  final String driverName;
  final double amount;
  final String bankName;
  final String bankAccount;
  final DateTime requestDate;
  String status; // 'pending', 'approved', 'rejected'

  WithdrawalRequest({
    required this.id,
    required this.driverName,
    required this.amount,
    this.bankName = 'กสิกรไทย (KBANK)',
    required this.bankAccount,
    required this.requestDate,
    this.status = 'pending',
  });
}

class VehiclePricingConfig {
  final String vehicleType;
  double basePrice;
  double pricePerKm;
  double minimumKm;

  VehiclePricingConfig({
    required this.vehicleType,
    required this.basePrice,
    required this.pricePerKm,
    this.minimumKm = 2.0,
  });
}

class PromoVoucher {
  final String code;
  final double discountAmount;
  final String discountType; // 'fixed' or 'percent'
  final int usageCount;
  final int maxUsage;
  final bool isActive;

  PromoVoucher({
    required this.code,
    required this.discountAmount,
    this.discountType = 'fixed',
    required this.usageCount,
    required this.maxUsage,
    this.isActive = true,
  });
}

enum ChatCategory { team, driver, customer, emergency }

class ChatMessage {
  final String id;
  final String sender;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    required this.isFromMe,
  });
}

class ChatRoom {
  final String id;
  final String name;
  final String subtitle;
  final ChatCategory category;
  final String avatarText;
  final bool isOnline;
  int unreadCount;
  final List<ChatMessage> messages;

  ChatRoom({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.avatarText,
    this.isOnline = true,
    this.unreadCount = 0,
    required this.messages,
  });
}

enum TrackingStatus {
  inTransit,
  arriving,
  available,
  sos,
  offline,
}

extension TrackingStatusX on TrackingStatus {
  String get thaiLabel {
    switch (this) {
      case TrackingStatus.inTransit:
        return 'กำลังนำส่ง (In Transit)';
      case TrackingStatus.arriving:
        return 'กำลังไปรับพัสดุ (Arriving)';
      case TrackingStatus.available:
        return 'สแตนด์บายพร้อมรับงาน (Available)';
      case TrackingStatus.sos:
        return '🚨 ขอความช่วยเหลือฉุกเฉิน (SOS)';
      case TrackingStatus.offline:
        return 'ออฟไลน์ / พักผ่อน (Offline)';
    }
  }
}

class TrackingWaypoint {
  final String title;
  final String address;
  final String time;
  final bool isCompleted;
  final bool isCurrent;

  TrackingWaypoint({
    required this.title,
    required this.address,
    required this.time,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

class DriverTrackingInfo {
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String vehicleType;
  final String vehiclePlate;
  final String vehicleModel;
  final String vehicleColor;
  double topRatio; // 0.0 to 1.0
  double leftRatio; // 0.0 to 1.0
  double lat;
  double lng;
  double speedKmH;
  int batteryPercent;
  String signalStrength;
  TrackingStatus status;
  String currentRoad;
  String? activeOrderNo;
  String? customerName;
  String? customerPhone;
  String? pickupAddress;
  String? dropoffAddress;
  int etaMinutes;
  double distanceRemainingKm;
  double todayEarnings;
  int todayCompletedJobs;
  double rating;
  bool isSosAlert;
  String? sosReason;
  DateTime lastPing;
  List<TrackingWaypoint> waypoints;

  DriverTrackingInfo({
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.vehicleModel,
    this.vehicleColor = 'ดำ',
    required this.topRatio,
    required this.leftRatio,
    this.lat = 13.7563,
    this.lng = 100.5018,
    required this.speedKmH,
    required this.batteryPercent,
    this.signalStrength = '5G (ความแม่นยำ ±2ม.)',
    required this.status,
    required this.currentRoad,
    this.activeOrderNo,
    this.customerName,
    this.customerPhone,
    this.pickupAddress,
    this.dropoffAddress,
    this.etaMinutes = 0,
    this.distanceRemainingKm = 0.0,
    this.todayEarnings = 0.0,
    this.todayCompletedJobs = 0,
    this.rating = 4.9,
    this.isSosAlert = false,
    this.sosReason,
    required this.lastPing,
    required this.waypoints,
  });
}

