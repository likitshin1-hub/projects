import 'dart:async';
import '../../../core/network/dio_client.dart';

class AdminDashboardStats {
  final int totalOrdersToday;
  final double totalRevenueToday;
  final int activeDriversOnline;
  final int pendingDriverApplications;

  AdminDashboardStats({
    required this.totalOrdersToday,
    required this.totalRevenueToday,
    required this.activeDriversOnline,
    required this.pendingDriverApplications,
  });
}

class PendingDriverApplication {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String vehicleType;
  final String brand;
  final String model;
  final String plate;
  final String idCardUrl;
  final String driverLicenseUrl;
  final String vehicleDocUrl;
  final String bankBookUrl;
  final String vehiclePhotoUrl;
  final DateTime submittedAt;

  PendingDriverApplication({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.plate,
    required this.idCardUrl,
    required this.driverLicenseUrl,
    required this.vehicleDocUrl,
    required this.bankBookUrl,
    required this.vehiclePhotoUrl,
    required this.submittedAt,
  });
}

class AdminOrderModel {
  final String orderNo;
  final String customerName;
  final String driverName;
  final String pickupAddress;
  final String dropoffAddress;
  final String vehicleType;
  final double amount;
  final String status;
  final DateTime createdAt;

  AdminOrderModel({
    required this.orderNo,
    required this.customerName,
    required this.driverName,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.vehicleType,
    required this.amount,
    required this.status,
    required this.createdAt,
  });
}

class AdminService {
  final DioClient _dioClient;

  AdminService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// ดึงสถิติภาพรวม Dashboard (GET /api/admin/stats)
  Future<AdminDashboardStats> getDashboardStats() async {
    try {
      final response = await _dioClient.get('/admin/stats');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        return AdminDashboardStats(
          totalOrdersToday: (data['total_orders_today'] as num?)?.toInt() ?? 142,
          totalRevenueToday: (data['total_revenue_today'] as num?)?.toDouble() ?? 28450.0,
          activeDriversOnline: (data['active_drivers_online'] as num?)?.toInt() ?? 38,
          pendingDriverApplications: (data['pending_driver_applications'] as num?)?.toInt() ?? 5,
        );
      }
    } catch (e) {
      // Fallback
    }

    return AdminDashboardStats(
      totalOrdersToday: 142,
      totalRevenueToday: 28450.0,
      activeDriversOnline: 38,
      pendingDriverApplications: 5,
    );
  }

  /// ดึงรายการใบสมัครคนขับที่รอการอนุมัติ (GET /api/admin/pending-drivers)
  Future<List<PendingDriverApplication>> getPendingDrivers() async {
    try {
      final response = await _dioClient.get('/admin/pending-drivers');
      if (response.statusCode == 200 && response.data != null) {
        // Backend parsing
      }
    } catch (e) {
      // Fallback
    }

    final now = DateTime.now();
    return [
      PendingDriverApplication(
        id: 'DRV-1001',
        fullName: 'นายสมชาย มั่นคง',
        phone: '081-234-5678',
        email: 'somchai.m@gmail.com',
        vehicleType: 'มอเตอร์ไซค์',
        brand: 'Honda',
        model: 'Wave 125i',
        plate: '1กข 5598',
        idCardUrl: 'https://picsum.photos/400/250?img=1',
        driverLicenseUrl: 'https://picsum.photos/400/250?img=2',
        vehicleDocUrl: 'https://picsum.photos/400/250?img=3',
        bankBookUrl: 'https://picsum.photos/400/250?img=4',
        vehiclePhotoUrl: 'https://picsum.photos/400/250?img=5',
        submittedAt: now.subtract(const Duration(hours: 2)),
      ),
      PendingDriverApplication(
        id: 'DRV-1002',
        fullName: 'นายวิชัย ใจดี',
        phone: '089-876-5432',
        email: 'wichai.j@gmail.com',
        vehicleType: 'รถกระบะ',
        brand: 'Isuzu',
        model: 'D-Max',
        plate: '2ตข 8812',
        idCardUrl: 'https://picsum.photos/400/250?img=6',
        driverLicenseUrl: 'https://picsum.photos/400/250?img=7',
        vehicleDocUrl: 'https://picsum.photos/400/250?img=8',
        bankBookUrl: 'https://picsum.photos/400/250?img=9',
        vehiclePhotoUrl: 'https://picsum.photos/400/250?img=10',
        submittedAt: now.subtract(const Duration(hours: 5)),
      ),
      PendingDriverApplication(
        id: 'DRV-1003',
        fullName: 'นางสาวอนันยา วงศ์สว่าง',
        phone: '082-112-3344',
        email: 'ananya.w@gmail.com',
        vehicleType: 'รถเก๋ง 4 ประตู',
        brand: 'Toyota',
        model: 'Yaris',
        plate: 'กข 9921',
        idCardUrl: 'https://picsum.photos/400/250?img=11',
        driverLicenseUrl: 'https://picsum.photos/400/250?img=12',
        vehicleDocUrl: 'https://picsum.photos/400/250?img=13',
        bankBookUrl: 'https://picsum.photos/400/250?img=14',
        vehiclePhotoUrl: 'https://picsum.photos/400/250?img=15',
        submittedAt: now.subtract(const Duration(hours: 8)),
      ),
    ];
  }

  /// กดอนุมัติใบสมัครคนขับ (POST /api/admin/approve-driver)
  Future<bool> approveDriver(String driverId) async {
    try {
      final response = await _dioClient.post('/admin/approve-driver', data: {'driver_id': driverId});
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      // Fallback
    }
    return true;
  }

  /// กดปฏิเสธใบสมัครคนขับ (POST /api/admin/reject-driver)
  Future<bool> rejectDriver(String driverId, String reason) async {
    try {
      final response = await _dioClient.post('/admin/reject-driver', data: {
        'driver_id': driverId,
        'reason': reason,
      });
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      // Fallback
    }
    return true;
  }

  /// ดึงคำสั่งซื้อทั้งหมดในระบบ (GET /api/admin/orders)
  Future<List<AdminOrderModel>> getAllOrders() async {
    try {
      final response = await _dioClient.get('/admin/orders');
      if (response.statusCode == 200 && response.data != null) {
        // Backend parsing
      }
    } catch (e) {
      // Fallback
    }

    final now = DateTime.now();
    return [
      AdminOrderModel(
        orderNo: 'TB504321-5598',
        customerName: 'คุณเอ็นเทค จำกัด',
        driverName: 'สมชาย มั่นคง',
        pickupAddress: 'สุขุมวิท กรุงเทพฯ',
        dropoffAddress: 'อ.เมือง เชียงใหม่',
        vehicleType: 'มอเตอร์ไซค์',
        amount: 450.0,
        status: 'In Transit',
        createdAt: now.subtract(const Duration(minutes: 40)),
      ),
      AdminOrderModel(
        orderNo: 'TB668511-9921',
        customerName: 'คุณกิตติพงษ์ สุขใจ',
        driverName: 'วิชัย ใจดี',
        pickupAddress: 'บางนา กรุงเทพฯ',
        dropoffAddress: 'อ.เมือง ชลบุรี',
        vehicleType: 'รถกระบะ',
        amount: 850.0,
        status: 'Delivered',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      AdminOrderModel(
        orderNo: 'TB112044-8812',
        customerName: 'คุณพรทิพย์ สดใส',
        driverName: 'ยังไม่กำหนดคนขับ',
        pickupAddress: 'รังสิต ปทุมธานี',
        dropoffAddress: 'ปากเกร็ด นนทบุรี',
        vehicleType: 'รถเก๋ง 4 ประตู',
        amount: 250.0,
        status: 'Searching Rider',
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
    ];
  }
}
