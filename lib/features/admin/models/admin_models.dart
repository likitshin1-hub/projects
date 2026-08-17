enum DriverVerificationStatus { pending, approved, rejected, suspended }

enum AdminRole { superAdmin, admin, staff }

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
  String get label {
    switch (this) {
      case AdminOrderStatus.pending:
        return 'PENDING';
      case AdminOrderStatus.accepted:
        return 'ACCEPTED';
      case AdminOrderStatus.driverArriving:
        return 'DRIVER_ARRIVING';
      case AdminOrderStatus.pickedUp:
        return 'PICKED_UP';
      case AdminOrderStatus.inTransit:
        return 'IN_TRANSIT';
      case AdminOrderStatus.completed:
        return 'COMPLETED';
      case AdminOrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String get thaiLabel {
    switch (this) {
      case AdminOrderStatus.pending:
        return 'รอคนขับตอบรับ (Pending)';
      case AdminOrderStatus.accepted:
        return 'คนขับรับงานแล้ว (Accepted)';
      case AdminOrderStatus.driverArriving:
        return 'คนขับกำลังไปจุดรับ (Arriving)';
      case AdminOrderStatus.pickedUp:
        return 'รับของ/ผู้โดยสารแล้ว (Picked Up)';
      case AdminOrderStatus.inTransit:
        return 'กำลังนำส่ง (In Transit)';
      case AdminOrderStatus.completed:
        return 'จัดส่งสำเร็จ (Completed)';
      case AdminOrderStatus.cancelled:
        return 'ยกเลิกคำสั่งซื้อ (Cancelled)';
    }
  }

  bool get canCustomerCancel {
    switch (this) {
      case AdminOrderStatus.pending:
      case AdminOrderStatus.accepted:
      case AdminOrderStatus.driverArriving:
        return true;
      case AdminOrderStatus.pickedUp:
      case AdminOrderStatus.inTransit:
      case AdminOrderStatus.completed:
      case AdminOrderStatus.cancelled:
        return false;
    }
  }
}

class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int totalOrders;
  final double totalSpent;
  final bool isSuspended;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.totalOrders,
    required this.totalSpent,
    this.isSuspended = false,
    required this.createdAt,
  });

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? totalOrders,
    double? totalSpent,
    bool? isSuspended,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      isSuspended: isSuspended ?? this.isSuspended,
      createdAt: createdAt ?? this.createdAt,
    );
  }
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
  final String color;
  final DriverVerificationStatus status;
  final bool isOnline;
  final String idCardUrl;
  final String driverLicenseUrl;
  final String vehicleDocUrl;
  final String bankBookUrl;
  final String vehiclePhotoUrl;
  final String? rejectionReason;
  final double rating;
  final double walletBalance;
  final double totalEarnings;
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
    required this.color,
    required this.status,
    required this.isOnline,
    required this.idCardUrl,
    required this.driverLicenseUrl,
    required this.vehicleDocUrl,
    required this.bankBookUrl,
    required this.vehiclePhotoUrl,
    this.rejectionReason,
    this.rating = 4.9,
    this.walletBalance = 0.0,
    this.totalEarnings = 0.0,
    required this.submittedAt,
  });

  DriverAdminModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    String? vehicleType,
    String? brand,
    String? model,
    String? plate,
    String? color,
    DriverVerificationStatus? status,
    bool? isOnline,
    String? idCardUrl,
    String? driverLicenseUrl,
    String? vehicleDocUrl,
    String? bankBookUrl,
    String? vehiclePhotoUrl,
    String? rejectionReason,
    double? rating,
    double? walletBalance,
    double? totalEarnings,
    DateTime? submittedAt,
  }) {
    return DriverAdminModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      vehicleType: vehicleType ?? this.vehicleType,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      plate: plate ?? this.plate,
      color: color ?? this.color,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      idCardUrl: idCardUrl ?? this.idCardUrl,
      driverLicenseUrl: driverLicenseUrl ?? this.driverLicenseUrl,
      vehicleDocUrl: vehicleDocUrl ?? this.vehicleDocUrl,
      bankBookUrl: bankBookUrl ?? this.bankBookUrl,
      vehiclePhotoUrl: vehiclePhotoUrl ?? this.vehiclePhotoUrl,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rating: rating ?? this.rating,
      walletBalance: walletBalance ?? this.walletBalance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}

class AdminUserModel {
  final String id;
  final String name;
  final String email;
  final AdminRole role;
  final bool isActive;
  final DateTime lastLogin;

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    required this.lastLogin,
  });

  AdminUserModel copyWith({
    String? id,
    String? name,
    String? email,
    AdminRole? role,
    bool? isActive,
    DateTime? lastLogin,
  }) {
    return AdminUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

class AdminOrderModel {
  final String orderNo;
  final String customerName;
  final String customerPhone;
  final String driverName;
  final String driverPhone;
  final String vehicleType;
  final String pickupAddress;
  final String dropoffAddress;
  final double amount;
  final AdminOrderStatus status;
  final String? cancellationReason;
  final String? cancelledBy;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double currentDriverLat;
  final double currentDriverLng;
  final DateTime createdAt;

  AdminOrderModel({
    required this.orderNo,
    required this.customerName,
    required this.customerPhone,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleType,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.amount,
    required this.status,
    this.cancellationReason,
    this.cancelledBy,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.currentDriverLat,
    required this.currentDriverLng,
    required this.createdAt,
  });

  AdminOrderModel copyWith({
    String? orderNo,
    String? customerName,
    String? customerPhone,
    String? driverName,
    String? driverPhone,
    String? vehicleType,
    String? pickupAddress,
    String? dropoffAddress,
    double? amount,
    AdminOrderStatus? status,
    String? cancellationReason,
    String? cancelledBy,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    double? currentDriverLat,
    double? currentDriverLng,
    DateTime? createdAt,
  }) {
    return AdminOrderModel(
      orderNo: orderNo ?? this.orderNo,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      vehicleType: vehicleType ?? this.vehicleType,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      currentDriverLat: currentDriverLat ?? this.currentDriverLat,
      currentDriverLng: currentDriverLng ?? this.currentDriverLng,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class VehicleTypeConfig {
  final String id;
  final String name;
  final String iconName;
  final double basePrice;
  final double pricePerKm;
  final double platformFeePercent;

  VehicleTypeConfig({
    required this.id,
    required this.name,
    required this.iconName,
    required this.basePrice,
    required this.pricePerKm,
    required this.platformFeePercent,
  });

  VehicleTypeConfig copyWith({
    String? id,
    String? name,
    String? iconName,
    double? basePrice,
    double? pricePerKm,
    double? platformFeePercent,
  }) {
    return VehicleTypeConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      basePrice: basePrice ?? this.basePrice,
      pricePerKm: pricePerKm ?? this.pricePerKm,
      platformFeePercent: platformFeePercent ?? this.platformFeePercent,
    );
  }
}
