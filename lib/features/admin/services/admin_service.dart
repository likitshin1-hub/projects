import 'dart:async';
import '../models/admin_models.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/push_notification_service.dart';

class AdminService {
  final DioClient _dioClient;

  AdminService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  // Mock Customers Data
  final List<CustomerModel> _customers = [
    CustomerModel(
      id: 'CUST-101',
      name: 'คุณเอ็นเทค จำกัด',
      email: 'contact@ntech.co.th',
      phone: '081-998-7766',
      totalOrders: 28,
      totalSpent: 18450.0,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    CustomerModel(
      id: 'CUST-102',
      name: 'คุณกิตติพงษ์ สุขใจ',
      email: 'kittipong.s@gmail.com',
      phone: '089-112-3344',
      totalOrders: 14,
      totalSpent: 6200.0,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    CustomerModel(
      id: 'CUST-103',
      name: 'คุณพรทิพย์ สดใส',
      email: 'porntip.s@hotmail.com',
      phone: '086-443-2211',
      totalOrders: 7,
      totalSpent: 2890.0,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    CustomerModel(
      id: 'CUST-104',
      name: 'คุณธีรเดช รัตนะ',
      email: 'theeradech.r@yahoo.com',
      phone: '082-554-9988',
      totalOrders: 42,
      totalSpent: 34100.0,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
    ),
  ];

  // Mock Drivers Data
  final List<DriverAdminModel> _drivers = [
    DriverAdminModel(
      id: 'DRV-1001',
      fullName: 'นายสมชาย มั่นคง',
      phone: '081-234-5678',
      email: 'somchai.m@gmail.com',
      vehicleType: 'มอเตอร์ไซค์',
      brand: 'Honda',
      model: 'Wave 125i',
      plate: '1กข 5598',
      color: 'สีดำ-แดง',
      status: DriverVerificationStatus.pending,
      isOnline: true,
      idCardUrl: 'https://picsum.photos/400/250?img=1',
      driverLicenseUrl: 'https://picsum.photos/400/250?img=2',
      vehicleDocUrl: 'https://picsum.photos/400/250?img=3',
      bankBookUrl: 'https://picsum.photos/400/250?img=4',
      vehiclePhotoUrl: 'https://picsum.photos/400/250?img=5',
      rating: 4.9,
      walletBalance: 4850.0,
      totalEarnings: 32400.0,
      submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    DriverAdminModel(
      id: 'DRV-1002',
      fullName: 'นายวิชัย ใจดี',
      phone: '089-876-5432',
      email: 'wichai.j@gmail.com',
      vehicleType: 'รถกระบะ',
      brand: 'Isuzu',
      model: 'D-Max',
      plate: '2ตข 8812',
      color: 'สีขาว',
      status: DriverVerificationStatus.approved,
      isOnline: true,
      idCardUrl: 'https://picsum.photos/400/250?img=6',
      driverLicenseUrl: 'https://picsum.photos/400/250?img=7',
      vehicleDocUrl: 'https://picsum.photos/400/250?img=8',
      bankBookUrl: 'https://picsum.photos/400/250?img=9',
      vehiclePhotoUrl: 'https://picsum.photos/400/250?img=10',
      rating: 4.8,
      walletBalance: 8200.0,
      totalEarnings: 74500.0,
      submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    DriverAdminModel(
      id: 'DRV-1003',
      fullName: 'นางสาวอนันยา วงศ์สว่าง',
      phone: '082-112-3344',
      email: 'ananya.w@gmail.com',
      vehicleType: 'รถเก๋ง 4 ประตู',
      brand: 'Toyota',
      model: 'Yaris',
      plate: 'กข 9921',
      color: 'สีเทา',
      status: DriverVerificationStatus.approved,
      isOnline: false,
      idCardUrl: 'https://picsum.photos/400/250?img=11',
      driverLicenseUrl: 'https://picsum.photos/400/250?img=12',
      vehicleDocUrl: 'https://picsum.photos/400/250?img=13',
      bankBookUrl: 'https://picsum.photos/400/250?img=14',
      vehiclePhotoUrl: 'https://picsum.photos/400/250?img=15',
      rating: 5.0,
      walletBalance: 1450.0,
      totalEarnings: 18900.0,
      submittedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    DriverAdminModel(
      id: 'DRV-1004',
      fullName: 'นายเกรียงไกร ชาญชัย',
      phone: '085-776-1122',
      email: 'kriengkrai.c@gmail.com',
      vehicleType: 'รถตู้บรรทุก',
      brand: 'Toyota',
      model: 'Commuter',
      plate: '3ฮฮ 4410',
      color: 'สีเงิน',
      status: DriverVerificationStatus.pending,
      isOnline: false,
      idCardUrl: 'https://picsum.photos/400/250?img=16',
      driverLicenseUrl: 'https://picsum.photos/400/250?img=17',
      vehicleDocUrl: 'https://picsum.photos/400/250?img=18',
      bankBookUrl: 'https://picsum.photos/400/250?img=19',
      vehiclePhotoUrl: 'https://picsum.photos/400/250?img=20',
      rating: 4.7,
      walletBalance: 0.0,
      totalEarnings: 0.0,
      submittedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  // Mock Admins Data
  final List<AdminUserModel> _admins = [
    AdminUserModel(
      id: 'ADM-01',
      name: 'Super Admin System',
      email: 'admin@tbmovehub.com',
      role: AdminRole.superAdmin,
      isActive: true,
      lastLogin: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    AdminUserModel(
      id: 'ADM-02',
      name: 'คุณณัฐพล ผู้จัดการฝ่ายปฏิบัติการ',
      email: 'nattaphol.m@tbmovehub.com',
      role: AdminRole.admin,
      isActive: true,
      lastLogin: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AdminUserModel(
      id: 'ADM-03',
      name: 'คุณสุชาดา เจ้าหน้าที่ซัพพอร์ต',
      email: 'suchada.s@tbmovehub.com',
      role: AdminRole.staff,
      isActive: true,
      lastLogin: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Mock Orders Data
  final List<AdminOrderModel> _orders = [
    AdminOrderModel(
      orderNo: 'TB504321-5598',
      customerName: 'คุณเอ็นเทค จำกัด',
      customerPhone: '081-998-7766',
      driverName: 'สมชาย มั่นคง',
      driverPhone: '081-234-5678',
      vehicleType: 'มอเตอร์ไซค์',
      pickupAddress: 'อาคารสยามทาวเวอร์ ปทุมวัน กรุงเทพฯ',
      dropoffAddress: 'เซ็นทรัลลาดพร้าว จตุจักร กรุงเทพฯ',
      amount: 450.0,
      status: AdminOrderStatus.inTransit,
      pickupLat: 13.7462,
      pickupLng: 100.5347,
      dropoffLat: 13.8160,
      dropoffLng: 100.5612,
      currentDriverLat: 13.7800,
      currentDriverLng: 100.5480,
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
    ),
    AdminOrderModel(
      orderNo: 'TB668511-9921',
      customerName: 'คุณกิตติพงษ์ สุขใจ',
      customerPhone: '089-112-3344',
      driverName: 'วิชัย ใจดี',
      driverPhone: '089-876-5432',
      vehicleType: 'รถกระบะ',
      pickupAddress: 'เมกาบางนา บางพลี สมุทรปราการ',
      dropoffAddress: 'นิคมอุตสาหกรรมอมตะซิตี้ อ.เมือง ชลบุรี',
      amount: 850.0,
      status: AdminOrderStatus.completed,
      pickupLat: 13.6465,
      pickupLng: 100.6800,
      dropoffLat: 13.3611,
      dropoffLng: 100.9847,
      currentDriverLat: 13.3611,
      currentDriverLng: 100.9847,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AdminOrderModel(
      orderNo: 'TB112044-8812',
      customerName: 'คุณพรทิพย์ สดใส',
      customerPhone: '086-443-2211',
      driverName: 'ยังไม่ได้ระบุคนขับ',
      driverPhone: '-',
      vehicleType: 'รถเก๋ง 4 ประตู',
      pickupAddress: 'ฟิวเจอร์พาร์ครังสิต ธัญบุรี ปทุมธานี',
      dropoffAddress: 'แจ้งวัฒนะ ปากเกร็ด นนทบุรี',
      amount: 250.0,
      status: AdminOrderStatus.pending,
      pickupLat: 13.9890,
      pickupLng: 100.6180,
      dropoffLat: 13.8980,
      dropoffLng: 100.5520,
      currentDriverLat: 13.9890,
      currentDriverLng: 100.6180,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    AdminOrderModel(
      orderNo: 'TB991200-4410',
      customerName: 'คุณธีรเดช รัตนะ',
      customerPhone: '082-554-9988',
      driverName: 'อนันยา วงศ์สว่าง',
      driverPhone: '082-112-3344',
      vehicleType: 'รถเก๋ง 4 ประตู',
      pickupAddress: 'เอกมัย วัฒนา กรุงเทพฯ',
      dropoffAddress: 'สนามบินสุวรรณภูมิ บางพลี สมุทรปราการ',
      amount: 650.0,
      status: AdminOrderStatus.cancelled,
      cancellationReason: 'ลูกค้าขอยกเลิกเนื่องจากเปลี่ยนเวลาเดินทาง',
      cancelledBy: 'Customer',
      pickupLat: 13.7310,
      pickupLng: 100.5850,
      dropoffLat: 13.6900,
      dropoffLng: 100.7501,
      currentDriverLat: 13.7310,
      currentDriverLng: 100.5850,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  // Vehicle configs
  final List<VehicleTypeConfig> _vehicleConfigs = [
    VehicleTypeConfig(id: 'v1', name: 'มอเตอร์ไซค์', iconName: 'two_wheeler', basePrice: 35.0, pricePerKm: 12.0, platformFeePercent: 15.0),
    VehicleTypeConfig(id: 'v2', name: 'รถเก๋ง 4 ประตู', iconName: 'directions_car', basePrice: 65.0, pricePerKm: 18.0, platformFeePercent: 15.0),
    VehicleTypeConfig(id: 'v3', name: 'รถกระบะ', iconName: 'local_shipping', basePrice: 150.0, pricePerKm: 25.0, platformFeePercent: 12.0),
    VehicleTypeConfig(id: 'v4', name: 'รถตู้บรรทุก', iconName: 'airport_shuttle', basePrice: 300.0, pricePerKm: 35.0, platformFeePercent: 10.0),
  ];

  // Stream Controllers for Real-Time Live Sync
  final StreamController<List<AdminOrderModel>> _ordersStreamController = StreamController<List<AdminOrderModel>>.broadcast();
  final StreamController<List<DriverAdminModel>> _driversStreamController = StreamController<List<DriverAdminModel>>.broadcast();

  Stream<List<AdminOrderModel>> get ordersStream => _ordersStreamController.stream;
  Stream<List<DriverAdminModel>> get driversStream => _driversStreamController.stream;

  void _notifyOrdersChanged() {
    if (!_ordersStreamController.isClosed) {
      _ordersStreamController.add(List.unmodifiable(_orders));
    }
  }

  void _notifyDriversChanged() {
    if (!_driversStreamController.isClosed) {
      _driversStreamController.add(List.unmodifiable(_drivers));
    }
  }

  // Fetch Methods with DioClient API Integration & Fallback
  List<CustomerModel> getCustomersSync() => List.from(_customers);
  List<DriverAdminModel> getDriversSync() => List.from(_drivers);
  List<AdminUserModel> getAdminsSync() => List.from(_admins);
  List<AdminOrderModel> getOrdersSync() => List.from(_orders);
  List<VehicleTypeConfig> getVehicleConfigsSync() => List.from(_vehicleConfigs);

  Future<List<CustomerModel>> getCustomers() async {
    try {
      final response = await _dioClient.get('/admin/customers');
      if (response.data != null && response.data['data'] is List) {
        final List list = response.data['data'];
        return list.map((item) => CustomerModel.fromJson(item)).toList();
      }
    } catch (_) {
      // Fallback to local memory list
    }
    return List.from(_customers);
  }

  Future<List<DriverAdminModel>> getDrivers() async {
    try {
      final response = await _dioClient.get('/admin/drivers');
      if (response.data != null && response.data['data'] is List) {
        final List list = response.data['data'];
        final res = list.map((item) => DriverAdminModel.fromJson(item)).toList();
        _drivers.clear();
        _drivers.addAll(res);
        _notifyDriversChanged();
        return res;
      }
    } catch (_) {
      // Fallback to local memory list
    }
    return List.from(_drivers);
  }

  Future<List<AdminUserModel>> getAdmins() async {
    try {
      final response = await _dioClient.get('/admin/users');
      if (response.data != null && response.data['data'] is List) {
        final List list = response.data['data'];
        return list.map((item) => AdminUserModel.fromJson(item)).toList();
      }
    } catch (_) {
      // Fallback
    }
    return List.from(_admins);
  }

  Future<List<AdminOrderModel>> getOrders() async {
    try {
      final response = await _dioClient.get('/admin/orders');
      if (response.data != null && response.data['data'] is List) {
        final List list = response.data['data'];
        final res = list.map((item) => AdminOrderModel.fromJson(item)).toList();
        _orders.clear();
        _orders.addAll(res);
        _notifyOrdersChanged();
        return res;
      }
    } catch (_) {
      // Fallback
    }
    return List.from(_orders);
  }

  Future<List<VehicleTypeConfig>> getVehicleConfigs() async {
    try {
      final response = await _dioClient.get('/admin/vehicle-configs');
      if (response.data != null && response.data['data'] is List) {
        final List list = response.data['data'];
        return list.map((item) => VehicleTypeConfig.fromJson(item)).toList();
      }
    } catch (_) {
      // Fallback
    }
    return List.from(_vehicleConfigs);
  }

  // Actions
  Future<bool> updateCustomerInfo(String id, String name, String email, String phone) async {
    try {
      await _dioClient.put('/admin/customers/$id', data: {
        'name': name,
        'email': email,
        'phone': phone,
      });
    } catch (_) {}

    final idx = _customers.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _customers[idx] = _customers[idx].copyWith(
        name: name,
        email: email,
        phone: phone,
      );
      return true;
    }
    return false;
  }

  Future<bool> toggleCustomerStatus(String id) async {
    final idx = _customers.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _customers[idx] = _customers[idx].copyWith(isSuspended: !_customers[idx].isSuspended);
      return true;
    }
    return false;
  }

  Future<DriverAdminModel> registerDriverApplication({
    required String fullName,
    required String phone,
    required String email,
    required String vehicleType,
    required String brand,
    required String model,
    required String color,
    required String plate,
    required DateTime submittedAt,
  }) async {
    final newDriver = DriverAdminModel(
      id: 'DRV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      fullName: fullName.isNotEmpty ? fullName : 'ผู้สมัครไรเดอร์ท่านใหม่',
      phone: phone.isNotEmpty ? phone : '085-368-1345',
      email: email.isNotEmpty ? email : 'newdriver@tbmovehub.com',
      vehicleType: vehicleType.isNotEmpty ? vehicleType : 'รถจักรยานยนต์',
      brand: brand.isNotEmpty ? brand : 'Honda',
      model: model.isNotEmpty ? model : 'Wave 125i',
      plate: plate.isNotEmpty ? plate : '1กข 9999',
      color: color.isNotEmpty ? color : 'สีดำ',
      status: DriverVerificationStatus.pending,
      isOnline: false,
      idCardUrl: 'https://picsum.photos/400/250?img=1',
      driverLicenseUrl: 'https://picsum.photos/400/250?img=2',
      vehicleDocUrl: 'https://picsum.photos/400/250?img=3',
      bankBookUrl: 'https://picsum.photos/400/250?img=4',
      vehiclePhotoUrl: 'https://picsum.photos/400/250?img=5',
      rating: 5.0,
      walletBalance: 0.0,
      totalEarnings: 0.0,
      submittedAt: submittedAt,
    );

    _drivers.insert(0, newDriver);
    _notifyDriversChanged();

    try {
      await _dioClient.post('/admin/drivers/register', data: newDriver.toJson());
    } catch (_) {}

    return newDriver;
  }

  Future<bool> approveDriver(String id) async {
    try {
      await _dioClient.post('/admin/drivers/$id/approve');
    } catch (_) {}

    final idx = _drivers.indexWhere((d) => d.id == id);
    if (idx != -1) {
      _drivers[idx] = _drivers[idx].copyWith(
        status: DriverVerificationStatus.approved,
        rejectionReason: null,
      );
      _notifyDriversChanged();

      // Trigger Push Notification to Driver User Account
      PushNotificationService().triggerLocalPushNotification(
        title: '🎉 บัญชีผู้ให้บริการของคุณได้รับการอนุมัติแล้ว!',
        body: 'เอกสารสมัครคนขับของคุณ (${_drivers[idx].fullName}) ผ่านการอนุมัติเรียบร้อยแล้ว! คุณสามารถสลับโรลในหน้าโปรไฟล์เพื่อเริ่มต้นรับงานได้ทันที',
        extraData: {
          'driverId': id,
          'status': 'APPROVED',
          'type': 'driver_approval',
        },
      );

      return true;
    }
    return false;
  }

  Future<bool> rejectDriver(String id, String reason) async {
    try {
      await _dioClient.post('/admin/drivers/$id/reject', data: {'reason': reason});
    } catch (_) {}

    final idx = _drivers.indexWhere((d) => d.id == id);
    if (idx != -1) {
      _drivers[idx] = _drivers[idx].copyWith(
        status: DriverVerificationStatus.rejected,
        rejectionReason: reason,
      );
      _notifyDriversChanged();

      // Trigger Rejection Notification to Driver User Account
      PushNotificationService().triggerLocalPushNotification(
        title: '⚠️ เอกสารสมัครคนขับไม่ผ่านการอนุมัติ',
        body: 'การสมัครเป็นผู้ให้บริการสำหรับ ${_drivers[idx].fullName} ถูกปฏิเสธ: $reason กรุณาแก้ไขและยื่นเอกสารใหม่อีกครั้ง',
        extraData: {
          'driverId': id,
          'status': 'REJECTED',
          'reason': reason,
          'type': 'driver_rejection',
        },
      );

      return true;
    }
    return false;
  }

  Future<bool> toggleDriverSuspend(String id) async {
    try {
      await _dioClient.post('/admin/drivers/$id/toggle-suspend');
    } catch (_) {}

    final idx = _drivers.indexWhere((d) => d.id == id);
    if (idx != -1) {
      final current = _drivers[idx].status;
      final next = (current == DriverVerificationStatus.suspended)
          ? DriverVerificationStatus.approved
          : DriverVerificationStatus.suspended;
      _drivers[idx] = _drivers[idx].copyWith(status: next);
      _notifyDriversChanged();
      return true;
    }
    return false;
  }

  Future<bool> updateOrderStatus(String orderNo, AdminOrderStatus newStatus, {String? reason, String? cancelledBy}) async {
    try {
      await _dioClient.put('/admin/orders/$orderNo/status', data: {
        'status': newStatus.name,
        'reason': reason,
        'cancelled_by': cancelledBy,
      });
    } catch (_) {}

    final idx = _orders.indexWhere((o) => o.orderNo == orderNo);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(
        status: newStatus,
        cancellationReason: reason ?? _orders[idx].cancellationReason,
        cancelledBy: cancelledBy ?? _orders[idx].cancelledBy,
      );
      _notifyOrdersChanged();
      return true;
    }
    return false;
  }

  Future<bool> updateAdminUser(String id, String name, String email, AdminRole role) async {
    final idx = _admins.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _admins[idx] = _admins[idx].copyWith(
        name: name,
        email: email,
        role: role,
      );
      return true;
    }
    return false;
  }

  Future<bool> toggleAdminStatus(String id) async {
    final idx = _admins.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _admins[idx] = _admins[idx].copyWith(isActive: !_admins[idx].isActive);
      return true;
    }
    return false;
  }

  Future<bool> addAdminUser(String name, String email, AdminRole role) async {
    final newAdmin = AdminUserModel(
      id: 'ADM-0${_admins.length + 1}',
      name: name,
      email: email,
      role: role,
      isActive: true,
      lastLogin: DateTime.now(),
    );
    _admins.add(newAdmin);
    return true;
  }

  /// 🔌 Test Database / REST API Server Connectivity
  Future<Map<String, dynamic>> testDatabaseConnection() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dioClient.get('/admin/orders');
      stopwatch.stop();
      if (response.statusCode != null && response.statusCode! < 400) {
        return {
          'isOnline': true,
          'latencyMs': stopwatch.elapsedMilliseconds,
          'message': 'Connected to Real Database/API (HTTP ${response.statusCode})',
        };
      }
    } catch (e) {
      stopwatch.stop();
      return {
        'isOnline': false,
        'latencyMs': stopwatch.elapsedMilliseconds,
        'message': 'Database offline / Standby local sync engine: $e',
      };
    }
    return {
      'isOnline': false,
      'latencyMs': 0,
      'message': 'Database connection standby',
    };
  }

  /// 🔄 Force refresh all modules from live Database
  Future<void> forceRefreshAllFromDatabase() async {
    await Future.wait([
      getCustomers(),
      getDrivers(),
      getOrders(),
      getAdmins(),
      getVehicleConfigs(),
    ]);
  }
}
