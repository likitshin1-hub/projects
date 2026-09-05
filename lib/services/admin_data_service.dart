import 'dart:math';
import 'package:flutter/material.dart';
import '../models/admin_models.dart';

class AdminDataService extends ChangeNotifier {
  static final AdminDataService _instance = AdminDataService._internal();
  factory AdminDataService() => _instance;
  AdminDataService._internal() {
    _initData();
  }

  bool isDarkMode = false;
  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  AdminUserModel currentAdmin = AdminUserModel(
    id: 'A001',
    name: 'Super Admin',
    email: 'admin@tbmovehub.com',
    role: AdminRole.superAdmin,
    department: 'ศูนย์ปฏิบัติการใหญ่ HQ',
    lastLogin: DateTime.now(),
  );

  double platformFeePercent = 15.0;
  bool maintenanceMode = false;
  bool allowNewDriverReg = true;
  bool notifyNewOrder = true;
  bool notifyNewDriver = true;
  bool notifyWithdraw = true;
  String apiBaseUrl = 'http://127.0.0.1:8000/api';

  List<VehiclePricingConfig> pricingConfigs = [];
  List<CustomerModel> customers = [];
  List<DriverAdminModel> drivers = [];
  List<AdminOrderModel> orders = [];
  List<AdminUserModel> admins = [];
  List<WithdrawalRequest> withdrawals = [];
  List<PromoVoucher> promoVouchers = [];
  List<AuditLogItem> auditLogs = [];
  List<ChatRoom> chatRooms = [];
  List<DriverTrackingInfo> trackingDrivers = [];
  List<ComplaintTicket> complaints = [];

  // Map simulation

  double pin1Top = 80;
  double pin1Left = 120;
  double pin2Top = 180;
  double pin2Left = 320;
  double pin3Top = 280;
  double pin3Left = 160;
  double pin4Top = 120;
  double pin4Left = 450;
  double pin5Top = 220;
  double pin5Left = 240;

  void _initData() {
    pricingConfigs = [
      VehiclePricingConfig(vehicleType: '🛵 มอเตอร์ไซค์ (Motorcycle)', basePrice: 35.0, pricePerKm: 7.0, minimumKm: 2.0),
      VehiclePricingConfig(vehicleType: '🚗 รถกระบะ (Pickup Truck)', basePrice: 80.0, pricePerKm: 12.0, minimumKm: 3.0),
      VehiclePricingConfig(vehicleType: '🚛 รถบรรทุก 4 ล้อใหญ่ (Light Truck)', basePrice: 150.0, pricePerKm: 16.0, minimumKm: 5.0),
      VehiclePricingConfig(vehicleType: '🚚 รถบรรทุก 6 ล้อ (Heavy Truck)', basePrice: 350.0, pricePerKm: 25.0, minimumKm: 10.0),
    ];

    promoVouchers = [
      PromoVoucher(code: 'TBMOVE2026', discountAmount: 50.0, discountType: 'fixed', usageCount: 412, maxUsage: 1000),
      PromoVoucher(code: 'VIPFREESHIP', discountAmount: 100.0, discountType: 'fixed', usageCount: 88, maxUsage: 200),
      PromoVoucher(code: 'DISCOUNT15', discountAmount: 15.0, discountType: 'percent', usageCount: 654, maxUsage: 2000),
      PromoVoucher(code: 'WEEKEND30', discountAmount: 30.0, discountType: 'fixed', usageCount: 125, maxUsage: 500),
    ];

    customers = [
      CustomerModel(id: 'C001', name: 'สมชาย ใจดี', email: 'somchai@gmail.com', phone: '081-234-5678', address: 'คอนโดแอชตัน สุขุมวิท 38 กรุงเทพฯ', totalOrders: 42, totalSpent: 12450.0, rating: 4.9, isVip: true, createdAt: DateTime(2025, 3, 12)),
      CustomerModel(id: 'C002', name: 'นิภา รักสวย', email: 'nipa@hotmail.com', phone: '089-876-5432', address: 'หมู่บ้านพฤกษาวิลล์ ลาดพร้าว 101 กรุงเทพฯ', totalOrders: 17, totalSpent: 4800.0, rating: 4.8, createdAt: DateTime(2025, 5, 22)),
      CustomerModel(id: 'C003', name: 'วิชัย เร็วมาก (บจก. เอสเอ็มอี โลจิสติกส์)', email: 'wichai@sme-logis.co.th', phone: '062-111-2222', address: 'อาคารเอ็มไพร์ ทาวเวอร์ สาทรใต้ กรุงเทพฯ', totalOrders: 89, totalSpent: 35200.0, rating: 5.0, isVip: true, createdAt: DateTime(2024, 11, 1)),
      CustomerModel(
        id: 'C004',
        name: 'สุดา สวยงาม',
        email: 'suda@yahoo.com',
        phone: '094-333-4444',
        address: 'ซอยเจริญกรุง 40 บางรัก กรุงเทพฯ',
        totalOrders: 3,
        totalSpent: 720.0,
        rating: 2.1,
        isSuspended: true,
        suspensionReason: 'ปฏิเสธชำระเงินปลายทาง COD ซ้ำซ้อน และติดต่อไม่ได้',
        suspendedAt: DateTime.now().subtract(const Duration(days: 3)),
        suspensionDuration: '30 วัน',
        warningCount: 3,
        incidentTags: ['ปฏิเสธจ่าย COD', 'ติดต่อไม่ได้', 'ยกเลิกบ่อย'],
        createdAt: DateTime(2026, 1, 15),
      ),
      CustomerModel(id: 'C005', name: 'มนัส ดีใจ', email: 'manas@gmail.com', phone: '085-555-6666', address: 'ทองหล่อ ซอย 10 วัฒนา กรุงเทพฯ', totalOrders: 28, totalSpent: 9100.0, rating: 4.9, createdAt: DateTime(2025, 7, 8)),
      CustomerModel(id: 'C006', name: 'ปรีชา แก้วแท้', email: 'preecha@email.com', phone: '091-777-8888', address: 'หมู่บ้านมัณฑนา บางนา กม.7 สมุทรปราการ', totalOrders: 11, totalSpent: 2340.0, rating: 4.7, createdAt: DateTime(2025, 9, 30)),
      CustomerModel(id: 'C007', name: 'ลักษณา มีสุข', email: 'laksana@live.com', phone: '083-999-0000', address: 'คอนโดไอดีโอ คิว พระราม 4 ปทุมวัน กรุงเทพฯ', totalOrders: 65, totalSpent: 22800.0, rating: 5.0, isVip: true, createdAt: DateTime(2024, 8, 14)),
      CustomerModel(id: 'C008', name: 'ธนกร พอใจ', email: 'thanakorn@tech.io', phone: '076-101-2020', address: 'ทาวน์อินทาวน์ ซอย 3 วังทองหลาง กรุงเทพฯ', totalOrders: 19, totalSpent: 5400.0, rating: 4.6, createdAt: DateTime(2025, 10, 18)),
      CustomerModel(id: 'C009', name: 'กนกวรรณ รุ่งเรือง', email: 'kanokwan@fashion.th', phone: '088-345-6789', address: 'ศูนย์การค้าสยามสแควร์วัน ปทุมวัน กรุงเทพฯ', totalOrders: 54, totalSpent: 18900.0, rating: 4.9, isVip: true, createdAt: DateTime(2024, 12, 5)),
      CustomerModel(id: 'C010', name: 'เอกราช ก้องเกียรติ', email: 'ekkarat@supply.com', phone: '082-890-1234', address: 'นิคมอุตสาหกรรมบางชัน มีนบุรี กรุงเทพฯ', totalOrders: 33, totalSpent: 14200.0, rating: 4.8, createdAt: DateTime(2025, 4, 10)),
      CustomerModel(
        id: 'C011',
        name: 'ภานุมาศ ใจร้อน',
        email: 'panumas@temp.com',
        phone: '095-888-7711',
        address: 'ซอยรัชดาภิเษก 3 ดินแดง กรุงเทพฯ',
        totalOrders: 6,
        totalSpent: 1450.0,
        rating: 1.8,
        isSuspended: false,
        warningCount: 2,
        incidentTags: ['ข่มขู่ไรเดอร์', 'ใช้ถ้อยคำหยาบคาย'],
        createdAt: DateTime(2025, 11, 20),
      ),
      CustomerModel(
        id: 'C012',
        name: 'วรพล นามสมมุติ',
        email: 'worapol@spam.net',
        phone: '084-222-1100',
        address: 'พหลโยธิน ซอย 8 สามเสนใน พญาไท',
        totalOrders: 4,
        totalSpent: 380.0,
        rating: 1.5,
        isSuspended: true,
        suspensionReason: 'สร้างออเดอร์ปลอม แกล้งสั่งแล้วยกเลิกงานต่อเนื่อง 4 ครั้ง',
        suspendedAt: DateTime.now().subtract(const Duration(days: 1)),
        suspensionDuration: 'ถาวร (Permanent)',
        warningCount: 3,
        incidentTags: ['แกล้งสั่งสินค้า', 'ยกเลิกถี่ผิดปกติ'],
        createdAt: DateTime(2026, 2, 1),
      ),
    ];

    drivers = [
      DriverAdminModel(id: 'D001', fullName: 'สมหมาย ขับดี', phone: '081-111-2233', email: 'sommai@rider.com', vehicleType: '🛵 มอเตอร์ไซค์', brand: 'Honda', model: 'PCX 160', plate: '1กข 1234', province: 'กรุงเทพฯ', color: 'ดำด้าน', status: DriverVerificationStatus.approved, isOnline: true, rating: 4.95, completedJobs: 480, walletBalance: 3240.0, totalEarnings: 84500.0, area: 'สุขุมวิท - อโศก', submittedAt: DateTime(2025, 1, 10)),
      DriverAdminModel(id: 'D002', fullName: 'ประยุทธ์ ส่งเร็ว', phone: '085-222-3344', email: 'prayuth@rider.com', vehicleType: '🚗 รถกระบะตู้ทึบ', brand: 'Toyota', model: 'Hilux Revo 2.4', plate: '2คง 5678', province: 'กรุงเทพฯ', color: 'ขาว', status: DriverVerificationStatus.approved, isOnline: true, rating: 4.80, completedJobs: 310, walletBalance: 1800.0, totalEarnings: 62000.0, area: 'ลาดพร้าว - รัชดา', submittedAt: DateTime(2025, 2, 15)),
      DriverAdminModel(id: 'D003', fullName: 'อนงค์ ทำงานดี', phone: '089-333-4455', email: 'anong@rider.com', vehicleType: '🛵 มอเตอร์ไซค์', brand: 'Yamaha', model: 'NMAX 155', plate: '3งจ 9012', province: 'นนทบุรี', color: 'แดงเมทัลลิก', status: DriverVerificationStatus.pending, isOnline: false, rating: 0.0, completedJobs: 0, walletBalance: 0.0, totalEarnings: 0.0, area: 'งามวงศ์วาน - ติวานนท์', submittedAt: DateTime.now().subtract(const Duration(hours: 4))),
      DriverAdminModel(id: 'D004', fullName: 'บุญมี มีน้ำใจ', phone: '062-444-5566', email: 'boonmee@rider.com', vehicleType: '🚛 รถบรรทุก 4 ล้อใหญ่', brand: 'Isuzu', model: 'ELF NLR 130', plate: '4ฉช 3456', province: 'สมุทรปราการ', color: 'เทา-เงิน', status: DriverVerificationStatus.approved, isOnline: false, rating: 4.88, completedJobs: 520, walletBalance: 5600.0, totalEarnings: 128000.0, area: 'บางนา - เทพารักษ์', submittedAt: DateTime(2024, 12, 1)),
      DriverAdminModel(id: 'D005', fullName: 'กมลชนก เพิ่งมาสมัคร', phone: '094-555-6677', email: 'kamonchok@rider.com', vehicleType: '🛵 มอเตอร์ไซค์', brand: 'Honda', model: 'Click 160', plate: '5ซฌ 7890', province: 'กรุงเทพฯ', color: 'น้ำเงิน', status: DriverVerificationStatus.pending, isOnline: false, rating: 0.0, completedJobs: 0, walletBalance: 0.0, totalEarnings: 0.0, area: 'สยาม - ปทุมวัน', submittedAt: DateTime.now().subtract(const Duration(hours: 1))),
      DriverAdminModel(id: 'D006', fullName: 'ทวีป เคยโดนปฏิเสธ', phone: '091-666-7788', email: 'tawee@rider.com', vehicleType: '🚗 รถกระบะคอก', brand: 'Ford', model: 'Ranger Double Cab', plate: '6ญฎ 1111', province: 'ปทุมธานี', color: 'บรอนซ์เงิน', status: DriverVerificationStatus.rejected, isOnline: false, rating: 0.0, completedJobs: 0, walletBalance: 0.0, totalEarnings: 0.0, area: 'รังสิต - ลำลูกกา', submittedAt: DateTime(2026, 8, 20)),
      DriverAdminModel(id: 'D007', fullName: 'นิกร ถูกระงับ', phone: '083-777-8899', email: 'nikorn@rider.com', vehicleType: '🛵 มอเตอร์ไซค์', brand: 'Kawasaki', model: 'Z300', plate: '7ฏฐ 2222', province: 'กรุงเทพฯ', color: 'เขียว', status: DriverVerificationStatus.suspended, isOnline: false, rating: 3.10, completedJobs: 42, walletBalance: 200.0, totalEarnings: 9800.0, area: 'พระราม 2 - บางขุนเทียน', submittedAt: DateTime(2025, 6, 15)),
      DriverAdminModel(id: 'D008', fullName: 'อดิศร ซิ่งไว', phone: '087-123-9988', email: 'adisorn@rider.com', vehicleType: '🛵 มอเตอร์ไซค์', brand: 'Honda', model: 'Lead 125', plate: '8ณด 4455', province: 'กรุงเทพฯ', color: 'ขาว', status: DriverVerificationStatus.approved, isOnline: true, rating: 4.92, completedJobs: 290, walletBalance: 2450.0, totalEarnings: 53000.0, area: 'สีลม - สาทร', submittedAt: DateTime(2025, 4, 19)),
      DriverAdminModel(id: 'D009', fullName: 'อำนาจ ส่งทั่วไทย', phone: '086-456-7890', email: 'amnat@rider.com', vehicleType: '🚚 รถบรรทุก 6 ล้อ', brand: 'Hino', model: '500 Dominator', plate: '9ตถ 6677', province: 'กรุงเทพฯ', color: 'ขาว-น้ำเงิน', status: DriverVerificationStatus.approved, isOnline: true, rating: 4.98, completedJobs: 610, walletBalance: 8400.0, totalEarnings: 215000.0, area: 'มีนบุรี - ร่มเกล้า', submittedAt: DateTime(2024, 9, 1)),
    ];

    orders = [
      AdminOrderModel(orderNo: 'TB668511', customerName: 'สมชาย ใจดี', customerPhone: '081-234-5678', driverName: 'สมหมาย ขับดี', driverPhone: '081-111-2233', vehicleType: '🛵 มอเตอร์ไซค์', parcelType: 'เอกสารด่วนสัญญาสำคัญ', paymentMethod: 'PromptPay QR', distanceKm: 4.2, pickupAddress: 'คอนโดแอชตัน สุขุมวิท 38 กรุงเทพฯ', dropoffAddress: 'สถานี BTS อโศก แยกสุขุมวิท 21', amount: 85.0, status: AdminOrderStatus.completed, createdAt: DateTime.now().subtract(const Duration(minutes: 45))),
      AdminOrderModel(orderNo: 'TB668512', customerName: 'นิภา รักสวย', customerPhone: '089-876-5432', driverName: 'ประยุทธ์ ส่งเร็ว', driverPhone: '085-222-3344', vehicleType: '🚗 รถกระบะตู้ทึบ', parcelType: 'กล่องเสื้อผ้าแฟชั่น 6 ลัง', paymentMethod: 'บัตรเครดิต Visa', distanceKm: 12.8, pickupAddress: 'ลาดพร้าว 101 วังทองหลาง', dropoffAddress: 'เดอะสตรีท รัชดาภิเษก กรุงเทพฯ', amount: 240.0, status: AdminOrderStatus.inTransit, createdAt: DateTime.now().subtract(const Duration(minutes: 20))),
      AdminOrderModel(orderNo: 'TB668513', customerName: 'วิชัย เร็วมาก', customerPhone: '062-111-2222', driverName: 'รอคนขับตอบรับ', driverPhone: '-', vehicleType: '🚛 รถบรรทุก 4 ล้อใหญ่', parcelType: 'พาเลทชิ้นส่วนอะไหล่ยนต์ 300 กก.', paymentMethod: 'เงินสดปลายทาง (COD)', distanceKm: 24.5, pickupAddress: 'คลังสินค้า ดอนเมือง หลักสี่', dropoffAddress: 'อาคารเอ็มไพร์ สาทร กรุงเทพฯ', amount: 450.0, status: AdminOrderStatus.pending, createdAt: DateTime.now().subtract(const Duration(minutes: 5))),
      AdminOrderModel(orderNo: 'TB668514', customerName: 'สุดา สวยงาม', customerPhone: '094-333-4444', driverName: 'บุญมี มีน้ำใจ', driverPhone: '062-444-5566', vehicleType: '🛵 มอเตอร์ไซค์', parcelType: 'ช่อดอกไม้สดงานแต่ง', paymentMethod: 'TrueMoney Wallet', distanceKm: 3.1, pickupAddress: 'เจริญกรุง 40 บางรัก', dropoffAddress: 'โรงแรมดุสิตธานี สีลม', amount: 60.0, status: AdminOrderStatus.cancelled, createdAt: DateTime.now().subtract(const Duration(hours: 2))),
      AdminOrderModel(orderNo: 'TB668515', customerName: 'มนัส ดีใจ', customerPhone: '085-555-6666', driverName: 'สมหมาย ขับดี', driverPhone: '081-111-2233', vehicleType: '🛵 มอเตอร์ไซค์', parcelType: 'อุปกรณ์คอมพิวเตอร์พกพา', paymentMethod: 'PromptPay QR', distanceKm: 5.5, pickupAddress: 'ทองหล่อ ซอย 10 วัฒนา', dropoffAddress: 'เกตเวย์ เอกมัย ซอย 42', amount: 95.0, status: AdminOrderStatus.completed, createdAt: DateTime.now().subtract(const Duration(hours: 3))),
      AdminOrderModel(orderNo: 'TB668516', customerName: 'ลักษณา มีสุข', customerPhone: '083-999-0000', driverName: 'ประยุทธ์ ส่งเร็ว', driverPhone: '085-222-3344', vehicleType: '🚗 รถกระบะตู้ทึบ', parcelType: 'เฟอร์นิเจอร์โต๊ะทำงาน', paymentMethod: 'บัตรเครดิต Master', distanceKm: 8.9, pickupAddress: 'พระราม 4 บจก. ทีบีสโตร์', dropoffAddress: 'แพลทินัม ประตูน้ำ ราชเทวี', amount: 185.0, status: AdminOrderStatus.accepted, createdAt: DateTime.now().subtract(const Duration(minutes: 15))),
      AdminOrderModel(orderNo: 'TB668517', customerName: 'กนกวรรณ รุ่งเรือง', customerPhone: '088-345-6789', driverName: 'อดิศร ซิ่งไว', driverPhone: '087-123-9988', vehicleType: '🛵 มอเตอร์ไซค์', parcelType: 'เครื่องสำอางเซ็ตของขวัญ', paymentMethod: 'PromptPay QR', distanceKm: 6.2, pickupAddress: 'สยามสแควร์วัน ปทุมวัน', dropoffAddress: 'เซ็นทรัลพลาซา พระราม 9', amount: 110.0, status: AdminOrderStatus.inTransit, createdAt: DateTime.now().subtract(const Duration(minutes: 10))),
      AdminOrderModel(orderNo: 'TB668518', customerName: 'เอกราช ก้องเกียรติ', customerPhone: '082-890-1234', driverName: 'อำนาจ ส่งทั่วไทย', driverPhone: '086-456-7890', vehicleType: '🚚 รถบรรทุก 6 ล้อ', parcelType: 'วัสดุก่อสร้างเหล็กเส้น 2 ตัน', paymentMethod: 'โอนผ่านบัญชีบริษัท', distanceKm: 32.0, pickupAddress: 'นิคมบางชัน มีนบุรี', dropoffAddress: 'ไซต์งานก่อสร้าง พระราม 3', amount: 1250.0, status: AdminOrderStatus.inTransit, createdAt: DateTime.now().subtract(const Duration(minutes: 35))),
    ];

    admins = [
      AdminUserModel(id: 'A001', name: 'Super Admin', email: 'admin@tbmovehub.com', role: AdminRole.superAdmin, department: 'ศูนย์บริหารจัดการสูงสุด HQ', isActive: true, lastLogin: DateTime.now()),
      AdminUserModel(id: 'A002', name: 'ผู้จัดการ วรวุฒิ สิทธิโชค', email: 'manager@tbmovehub.com', role: AdminRole.admin, department: 'ฝ่ายปฏิบัติการ & ดูแลไรเดอร์', isActive: true, lastLogin: DateTime.now().subtract(const Duration(hours: 2))),
      AdminUserModel(id: 'A003', name: 'พนักงาน ปิยะ เจริญสุข', email: 'staff1@tbmovehub.com', role: AdminRole.staff, department: 'ฝ่ายตรวจสอบเอกสาร & อนุมัติ', isActive: true, lastLogin: DateTime.now().subtract(const Duration(days: 1))),
      AdminUserModel(id: 'A004', name: 'พนักงาน สมใจ สดใส', email: 'staff2@tbmovehub.com', role: AdminRole.staff, department: 'ฝ่ายการเงิน & คำขอถอนเงิน', isActive: true, lastLogin: DateTime.now().subtract(const Duration(hours: 5))),
      AdminUserModel(id: 'A005', name: 'ผู้ตรวจสอบ ชัชวาลย์', email: 'auditor@tbmovehub.com', role: AdminRole.auditor, department: 'ฝ่ายตรวจสอบระบบภายใน Audit', isActive: true, lastLogin: DateTime.now().subtract(const Duration(days: 3))),
    ];

    withdrawals = [
      WithdrawalRequest(id: 'W001', driverName: 'สมหมาย ขับดี', amount: 3240.0, bankName: 'กสิกรไทย (KBANK)', bankAccount: '009-1-23456-7', requestDate: DateTime.now().subtract(const Duration(hours: 2))),
      WithdrawalRequest(id: 'W002', driverName: 'บุญมี มีน้ำใจ', amount: 5600.0, bankName: 'กรุงเทพ (BBL)', bankAccount: '012-3-45678-9', requestDate: DateTime.now().subtract(const Duration(days: 1)), status: 'approved'),
      WithdrawalRequest(id: 'W003', driverName: 'ประยุทธ์ ส่งเร็ว', amount: 1800.0, bankName: 'ไทยพาณิชย์ (SCB)', bankAccount: '045-6-78901-2', requestDate: DateTime.now().subtract(const Duration(hours: 5))),
      WithdrawalRequest(id: 'W004', driverName: 'อดิศร ซิ่งไว', amount: 2450.0, bankName: 'กรุงไทย (KTB)', bankAccount: '112-0-99887-6', requestDate: DateTime.now().subtract(const Duration(hours: 1))),
      WithdrawalRequest(id: 'W005', driverName: 'อำนาจ ส่งทั่วไทย', amount: 8400.0, bankName: 'กสิกรไทย (KBANK)', bankAccount: '088-2-33445-5', requestDate: DateTime.now().subtract(const Duration(days: 2)), status: 'approved'),
    ];

    auditLogs = [
      AuditLogItem(id: 'LOG01', adminName: 'Super Admin', action: 'อนุมัติการสมัครไรเดอร์ใหม่', target: 'สมหมาย ขับดี (D001)', timestamp: DateTime.now().subtract(const Duration(minutes: 15))),
      AuditLogItem(id: 'LOG02', adminName: 'พนักงาน สมใจ', action: 'อนุมัติคำขอถอนเงิน', target: 'ยอด ฿5,600 (บุญมี มีน้ำใจ)', timestamp: DateTime.now().subtract(const Duration(hours: 1))),
      AuditLogItem(id: 'LOG03', adminName: 'ผู้จัดการ วรวุฒิ', action: 'ปรับเปลี่ยนสถานะคำสั่งซื้อ', target: 'ออเดอร์ TB668516 -> Accepted', timestamp: DateTime.now().subtract(const Duration(hours: 2))),
      AuditLogItem(id: 'LOG04', adminName: 'Super Admin', action: 'แก้ไขอัตราค่าบริการรถกระบะ', target: 'ปรับราคาต่อ กม. เป็น ฿12.0', timestamp: DateTime.now().subtract(const Duration(hours: 4))),
      AuditLogItem(id: 'LOG05', adminName: 'พนักงาน ปิยะ', action: 'ระงับบัญชีลูกค้าเนื่องจากผิดนโยบาย', target: 'สุดา สวยงาม (C004)', timestamp: DateTime.now().subtract(const Duration(days: 1))),
    ];

    chatRooms = [
      ChatRoom(
        id: 'team_general',
        name: '🏢 ทีมงานแอดมินกลาง (Team HQ)',
        subtitle: 'ห้องสื่อสารและประสานงานทีมแอดมิน',
        category: ChatCategory.team,
        avatarText: 'HQ',
        unreadCount: 1,
        messages: [
          ChatMessage(id: '1', sender: 'ผู้จัดการ วรวุฒิ', text: 'สวัสดีทีมงาน วันนี้มีไรเดอร์สมัครใหม่เข้ามา 5 ท่าน รบกวนช่วยตรวจสอบเอกสารด้วยครับ', timestamp: DateTime.now().subtract(const Duration(minutes: 30)), isFromMe: false),
          ChatMessage(id: '2', sender: 'พนักงาน ปิยะ', text: 'รับทราบครับ กำลังทยอยตรวจสอบบัตรและเล่มทะเบียนครับ', timestamp: DateTime.now().subtract(const Duration(minutes: 20)), isFromMe: false),
          ChatMessage(id: '3', sender: 'Super Admin', text: 'อนุมัติเรียบร้อยแล้ว 3 ท่านครับ ฝ่ายเทคนิคเตรียมมอนิเตอร์ระบบ Live Tracking นะครับ', timestamp: DateTime.now().subtract(const Duration(minutes: 5)), isFromMe: true),
        ],
      ),
      ChatRoom(
        id: 'team_finance',
        name: '💰 แผนกการเงิน (Finance Staff)',
        subtitle: 'ประสานงานยอดถอนเงินและรายงาน',
        category: ChatCategory.team,
        avatarText: 'FN',
        unreadCount: 0,
        messages: [
          ChatMessage(id: '1', sender: 'พนักงาน สมใจ', text: 'ยอดถอนเงินของไรเดอร์รอบเที่ยงอนุมัติครบแล้วนะคะ ยอดรวม ฿10,640', timestamp: DateTime.now().subtract(const Duration(hours: 2)), isFromMe: false),
          ChatMessage(id: '2', sender: 'Super Admin', text: 'ขอบคุณครับ ปิดรอบการเงินวันนี้ได้เลย', timestamp: DateTime.now().subtract(const Duration(hours: 1)), isFromMe: true),
        ],
      ),
      ChatRoom(
        id: 'emergency_sos',
        name: '🚨 ศูนย์รับแจ้งเหตุด่วน (Rider SOS)',
        subtitle: 'ช่องทางฉุกเฉิน อุบัติเหตุ/ปัญหาบนท้องถนน',
        category: ChatCategory.emergency,
        avatarText: 'SOS',
        unreadCount: 0,
        messages: [
          ChatMessage(id: '1', sender: 'ระบบอัตโนมัติ', text: '🟢 ศูนย์รับแจ้งเหตุพร้อมปฏิบัติการ 24 ชม.', timestamp: DateTime.now().subtract(const Duration(hours: 12)), isFromMe: false),
        ],
      ),
      ChatRoom(
        id: 'driver_sommai',
        name: 'สมหมาย ขับดี (ไรเดอร์)',
        subtitle: '🛵 มอเตอร์ไซค์ • ทะเบียน 1กข 1234',
        category: ChatCategory.driver,
        avatarText: 'สม',
        unreadCount: 1,
        messages: [
          ChatMessage(id: '1', sender: 'สมหมาย ขับดี', text: 'สวัสดีครับแอดมิน ถึงจุดรับพัสดุสุขุมวิท 11 แล้วครับ แต่ลูกค้ายังไม่ลงมารับสาย', timestamp: DateTime.now().subtract(const Duration(minutes: 10)), isFromMe: false),
          ChatMessage(id: '2', sender: 'Super Admin', text: 'สวัสดีครับคุณสมหมาย เดี๋ยวทางแอดมินช่วยโทรประสานงานลูกค้าให้อีกทางนะครับ', timestamp: DateTime.now().subtract(const Duration(minutes: 8)), isFromMe: true),
          ChatMessage(id: '3', sender: 'สมหมาย ขับดี', text: 'ขอบคุณมากครับแอดมิน ลูกค้าลงมารับแล้วครับ กำลังเดินทางนำส่งต่อครับ', timestamp: DateTime.now().subtract(const Duration(minutes: 2)), isFromMe: false),
        ],
      ),
      ChatRoom(
        id: 'driver_prayuth',
        name: 'ประยุทธ์ ส่งเร็ว (ไรเดอร์)',
        subtitle: '🚗 รถกระบะตู้ทึบ • ทะเบียน 2คง 5678',
        category: ChatCategory.driver,
        avatarText: 'ปร',
        unreadCount: 0,
        messages: [
          ChatMessage(id: '1', sender: 'ประยุทธ์ ส่งเร็ว', text: 'สอบถามเรื่องการขอถอนเงินครับ ยอดเข้าบัญชีกี่โมงครับ', timestamp: DateTime.now().subtract(const Duration(hours: 3)), isFromMe: false),
          ChatMessage(id: '2', sender: 'Super Admin', text: 'แอดมินดำเนินการอนุมัติให้เรียบร้อยแล้วครับ ยอดจะเข้าบัญชีภายใน 1-2 ชั่วโมงครับ', timestamp: DateTime.now().subtract(const Duration(hours: 2)), isFromMe: true),
        ],
      ),
      ChatRoom(
        id: 'cust_somchai',
        name: 'สมชาย ใจดี (ลูกค้า)',
        subtitle: '📦 ออเดอร์ TB668511 • สุขุมวิท 38',
        category: ChatCategory.customer,
        avatarText: 'ชย',
        unreadCount: 0,
        messages: [
          ChatMessage(id: '1', sender: 'สมชาย ใจดี', text: 'สวัสดีครับ สามารถเปลี่ยนจุดส่งปลายทางได้ไหมครับ', timestamp: DateTime.now().subtract(const Duration(hours: 4)), isFromMe: false),
          ChatMessage(id: '2', sender: 'Super Admin', text: 'หากไรเดอร์ยังไม่ได้รับของสามารถแก้ไขได้ครับ รบกวนแจ้งที่อยู่ใหม่ได้เลยครับ', timestamp: DateTime.now().subtract(const Duration(hours: 3)), isFromMe: true),
        ],
      ),
    ];

    trackingDrivers = [
      DriverTrackingInfo(
        driverId: 'D001',
        driverName: 'สมหมาย ขับดี',
        driverPhone: '081-111-2233',
        vehicleType: '🛵 มอเตอร์ไซค์',
        vehiclePlate: '1กข 1234 กทม.',
        vehicleModel: 'Honda PCX 160',
        vehicleColor: 'ดำด้าน',
        topRatio: 0.32,
        leftRatio: 0.45,
        speedKmH: 46.5,
        batteryPercent: 88,
        signalStrength: '5G (ความแม่นยำ ±1.5ม.)',
        status: TrackingStatus.inTransit,
        currentRoad: 'ถ.สุขุมวิท มุ่งหน้าแยกอโศกมนตรี',
        activeOrderNo: 'TB668511',
        customerName: 'สมชาย ใจดี',
        customerPhone: '081-234-5678',
        pickupAddress: 'คอนโดแอชตัน สุขุมวิท 38',
        dropoffAddress: 'สถานี BTS อโศก แยกสุขุมวิท 21',
        etaMinutes: 6,
        distanceRemainingKm: 1.8,
        todayEarnings: 850.0,
        todayCompletedJobs: 9,
        rating: 4.95,
        lastPing: DateTime.now().subtract(const Duration(seconds: 12)),
        waypoints: [
          TrackingWaypoint(title: 'รับพัสดุสำเร็จ', address: 'คอนโดแอชตัน สุขุมวิท 38', time: '14:30 น.', isCompleted: true),
          TrackingWaypoint(title: 'ผ่านแยกทองหล่อ', address: 'ถ.สุขุมวิท 55', time: '14:42 น.', isCompleted: true),
          TrackingWaypoint(title: 'จุดตรวจพิกัดปัจจุบัน', address: 'ถ.สุขุมวิท 23', time: '14:52 น.', isCurrent: true),
          TrackingWaypoint(title: 'จุดส่งมอบปลายทาง', address: 'สถานี BTS อโศก แยกสุขุมวิท 21', time: '14:58 น.'),
        ],
      ),
      DriverTrackingInfo(
        driverId: 'D002',
        driverName: 'ประยุทธ์ ส่งเร็ว',
        driverPhone: '085-222-3344',
        vehicleType: '🚗 รถกระบะตู้ทึบ',
        vehiclePlate: '2คง 5678 กทม.',
        vehicleModel: 'Toyota Hilux Revo 2.4',
        vehicleColor: 'ขาว',
        topRatio: 0.22,
        leftRatio: 0.65,
        speedKmH: 52.0,
        batteryPercent: 74,
        signalStrength: '5G (ความแม่นยำ ±2.0ม.)',
        status: TrackingStatus.inTransit,
        currentRoad: 'ถ.ลาดพร้าว ขาเข้ามุ่งหน้ารัชดาภิเษก',
        activeOrderNo: 'TB668512',
        customerName: 'นิภา รักสวย',
        customerPhone: '089-876-5432',
        pickupAddress: 'ลาดพร้าว 101 วังทองหลาง',
        dropoffAddress: 'เดอะสตรีท รัชดาภิเษก กรุงเทพฯ',
        etaMinutes: 14,
        distanceRemainingKm: 4.5,
        todayEarnings: 1240.0,
        todayCompletedJobs: 6,
        rating: 4.80,
        lastPing: DateTime.now().subtract(const Duration(seconds: 25)),
        waypoints: [
          TrackingWaypoint(title: 'รับกล่องเสื้อผ้า 6 ลัง', address: 'ลาดพร้าว 101', time: '14:15 น.', isCompleted: true),
          TrackingWaypoint(title: 'ผ่านแยกลาดพร้าว 80', address: 'ถ.ลาดพร้าว', time: '14:35 น.', isCompleted: true),
          TrackingWaypoint(title: 'จุดตรวจพิกัดปัจจุบัน', address: 'แยกรัชดา-ลาดพร้าว', time: '14:48 น.', isCurrent: true),
          TrackingWaypoint(title: 'จุดส่งมอบปลายทาง', address: 'เดอะสตรีท รัชดาภิเษก', time: '15:05 น.'),
        ],
      ),
      DriverTrackingInfo(
        driverId: 'D008',
        driverName: 'อดิศร ซิ่งไว',
        driverPhone: '087-123-9988',
        vehicleType: '🛵 มอเตอร์ไซค์',
        vehiclePlate: '8ณด 4455 กทม.',
        vehicleModel: 'Honda Lead 125',
        vehicleColor: 'ขาว',
        topRatio: 0.48,
        leftRatio: 0.38,
        speedKmH: 38.0,
        batteryPercent: 92,
        signalStrength: '5G (ความแม่นยำ ±1.0ม.)',
        status: TrackingStatus.arriving,
        currentRoad: 'ถ.พระราม 1 หน้าสยามพารากอน',
        activeOrderNo: 'TB668517',
        customerName: 'กนกวรรณ รุ่งเรือง',
        customerPhone: '088-345-6789',
        pickupAddress: 'สยามสแควร์วัน ปทุมวัน',
        dropoffAddress: 'เซ็นทรัลพลาซา พระราม 9',
        etaMinutes: 4,
        distanceRemainingKm: 0.9,
        todayEarnings: 680.0,
        todayCompletedJobs: 7,
        rating: 4.92,
        lastPing: DateTime.now().subtract(const Duration(seconds: 5)),
        waypoints: [
          TrackingWaypoint(title: 'ตอบรับคำสั่งซื้อ', address: 'ระบบจัดสรรงานอัตโนมัติ', time: '14:45 น.', isCompleted: true),
          TrackingWaypoint(title: 'กำลังมุ่งหน้าจุดรับ', address: 'สยามสแควร์วัน ปทุมวัน', time: '14:52 น.', isCurrent: true),
          TrackingWaypoint(title: 'ส่งมอบพัสดุปลายทาง', address: 'เซ็นทรัลพลาซา พระราม 9', time: '15:15 น.'),
        ],
      ),
      DriverTrackingInfo(
        driverId: 'D009',
        driverName: 'อำนาจ ส่งทั่วไทย',
        driverPhone: '086-456-7890',
        vehicleType: '🚚 รถบรรทุก 6 ล้อ',
        vehiclePlate: '9ตถ 6677 กทม.',
        vehicleModel: 'Hino 500 Dominator',
        vehicleColor: 'ขาว-น้ำเงิน',
        topRatio: 0.72,
        leftRatio: 0.76,
        speedKmH: 68.0,
        batteryPercent: 65,
        signalStrength: '4G+ (ความแม่นยำ ±3.5ม.)',
        status: TrackingStatus.inTransit,
        currentRoad: 'ถ.วงแหวนกาญจนาภิเษก มุ่งหน้าสะพานภูมิพล',
        activeOrderNo: 'TB668518',
        customerName: 'เอกราช ก้องเกียรติ',
        customerPhone: '082-890-1234',
        pickupAddress: 'นิคมบางชัน มีนบุรี',
        dropoffAddress: 'ไซต์งานก่อสร้าง พระราม 3',
        etaMinutes: 25,
        distanceRemainingKm: 14.2,
        todayEarnings: 4200.0,
        todayCompletedJobs: 3,
        rating: 4.98,
        lastPing: DateTime.now().subtract(const Duration(seconds: 18)),
        waypoints: [
          TrackingWaypoint(title: 'ขึ้นเหล็กเส้น 2 ตัน', address: 'นิคมบางชัน มีนบุรี', time: '13:40 น.', isCompleted: true),
          TrackingWaypoint(title: 'ผ่านด่านบางนา', address: 'ทางพิเศษกาญจนาภิเษก', time: '14:20 น.', isCompleted: true),
          TrackingWaypoint(title: 'จุดตรวจพิกัดปัจจุบัน', address: 'สะพานภูมิพล 1', time: '14:50 น.', isCurrent: true),
          TrackingWaypoint(title: 'ไซต์งานก่อสร้าง', address: 'พระราม 3 ริมแม่น้ำ', time: '15:20 น.'),
        ],
      ),
      DriverTrackingInfo(
        driverId: 'D004',
        driverName: 'บุญมี มีน้ำใจ',
        driverPhone: '062-444-5566',
        vehicleType: '🚛 รถบรรทุก 4 ล้อใหญ่',
        vehiclePlate: '4ฉช 3456 สมุทรปราการ',
        vehicleModel: 'Isuzu ELF NLR 130',
        vehicleColor: 'เทา-เงิน',
        topRatio: 0.68,
        leftRatio: 0.88,
        speedKmH: 0.0,
        batteryPercent: 95,
        signalStrength: '5G (ความแม่นยำ ±1.0ม.)',
        status: TrackingStatus.available,
        currentRoad: 'บางนา-ตราด กม.7 ลานจอดจุดพักรถ Hub 04',
        todayEarnings: 1840.0,
        todayCompletedJobs: 4,
        rating: 4.88,
        lastPing: DateTime.now().subtract(const Duration(seconds: 40)),
        waypoints: [],
      ),
      DriverTrackingInfo(
        driverId: 'D010',
        driverName: 'กิตติศักดิ์ พิทักษ์ไทย',
        driverPhone: '081-555-1212',
        vehicleType: '🛵 มอเตอร์ไซค์',
        vehiclePlate: '1ขก 9876 กทม.',
        vehicleModel: 'Yamaha Aerox 155',
        vehicleColor: 'น้ำเงินด้าน',
        topRatio: 0.38,
        leftRatio: 0.54,
        speedKmH: 0.0,
        batteryPercent: 41,
        signalStrength: '5G (ความแม่นยำ ±1.5ม.)',
        status: TrackingStatus.sos,
        isSosAlert: true,
        sosReason: '🚨 ยางหลังรั่ว รถสะดุดตะปูบน ถ.เพชรบุรีตัดใหม่ ใกล้ตึกชาญอิสสระ 2 ต้องการรถช่วยยก/รับพัสดุต่อด่วน',
        currentRoad: 'ถ.เพชรบุรีตัดใหม่ (ช่องจราจรซ้ายสุด ใกล้ตึกชาญอิสสระ 2)',
        activeOrderNo: 'TB668519',
        customerName: 'สุวิทย์ วงศ์สวัสดิ์',
        customerPhone: '081-555-8899',
        pickupAddress: 'แยกคลองตัน สวนหลวง',
        dropoffAddress: 'อาคารเสริมมิตร อโศก',
        etaMinutes: 0,
        distanceRemainingKm: 2.1,
        todayEarnings: 420.0,
        todayCompletedJobs: 4,
        rating: 4.89,
        lastPing: DateTime.now().subtract(const Duration(seconds: 3)),
        waypoints: [
          TrackingWaypoint(title: 'รับพัสดุสำเร็จ', address: 'แยกคลองตัน สวนหลวง', time: '14:20 น.', isCompleted: true),
          TrackingWaypoint(title: '🚨 เกิดเหตุยางรั่ว SOS', address: 'ถ.เพชรบุรีตัดใหม่ ใกล้ตึกชาญอิสสระ 2', time: '14:38 น.', isCurrent: true),
        ],
      ),
      DriverTrackingInfo(
        driverId: 'D011',
        driverName: 'ชาญชัย บริการดี',
        driverPhone: '089-999-8877',
        vehicleType: '🚗 รถกระบะตู้ทึบ',
        vehiclePlate: '3ฒณ 1423 กทม.',
        vehicleModel: 'Toyota Hilux Revo Smart Cab',
        vehicleColor: 'บรอนซ์เงิน',
        topRatio: 0.58,
        leftRatio: 0.32,
        speedKmH: 0.0,
        batteryPercent: 82,
        signalStrength: '5G (ความแม่นยำ ±1.2ม.)',
        status: TrackingStatus.available,
        currentRoad: 'ถ.สีลม หน้าอาคาร ซีพี ทาวเวอร์',
        todayEarnings: 950.0,
        todayCompletedJobs: 3,
        rating: 4.85,
        lastPing: DateTime.now().subtract(const Duration(seconds: 50)),
        waypoints: [],
      ),
      DriverTrackingInfo(
        driverId: 'D012',
        driverName: 'สุรชัย ส่งมั่นใจ',
        driverPhone: '083-444-1122',
        vehicleType: '🛵 มอเตอร์ไซค์',
        vehiclePlate: '5อบ 4411 กทม.',
        vehicleModel: 'Honda Wave 125i',
        vehicleColor: 'แดง-ดำ',
        topRatio: 0.82,
        leftRatio: 0.25,
        speedKmH: 0.0,
        batteryPercent: 28,
        signalStrength: '4G (ความแม่นยำ ±5.0ม.)',
        status: TrackingStatus.offline,
        currentRoad: 'ลาดกระบัง ซอย 14 (พักผ่อน)',
        todayEarnings: 1100.0,
        todayCompletedJobs: 11,
        rating: 4.79,
        lastPing: DateTime.now().subtract(const Duration(hours: 1)),
        waypoints: [],
      ),
    ];

    complaints = [
      ComplaintTicket(
        id: 'CMP-2026-081',
        orderNo: 'TB668514',
        reporterType: 'ไรเดอร์ (Driver)',
        reporterName: 'บุญมี มีน้ำใจ (D004)',
        reporterPhone: '062-444-5566',
        accusedCustomerId: 'C004',
        accusedCustomerName: 'สุดา สวยงาม',
        accusedCustomerPhone: '094-333-4444',
        category: 'ปฏิเสธชำระเงินปลายทาง (COD Reject)',
        severity: 'critical',
        description: 'นำส่งพัสดุดอกไม้สดถึงหน้าบ้านตามพิกัดเจริญกรุง 40 ลูกค้าปฏิเสธรับของและไม่ยอมจ่ายเงินสด COD ฿60 พร้อมปิดประตูหนีและตัดสายโทรศัพท์',
        evidenceSummary: '📸 ภาพถ่ายหน้าบ้านและพัสดุ + บันทึกประวัติการโทร 4 ครั้งไม่รับสาย',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ComplaintTicket(
        id: 'CMP-2026-082',
        orderNo: 'TB668512',
        reporterType: 'ไรเดอร์ (Driver)',
        reporterName: 'ประยุทธ์ ส่งเร็ว (D002)',
        reporterPhone: '085-222-3344',
        accusedCustomerId: 'C011',
        accusedCustomerName: 'ภานุมาศ ใจร้อน',
        accusedCustomerPhone: '095-888-7711',
        category: 'พฤติกรรมก้าวร้าว / ข่มขู่ไรเดอร์ (Verbal Abuse)',
        severity: 'high',
        description: 'ลูกค้าโมโหเนื่องจากสภาพการจราจรติดขัด ใช้คำหยาบคายด่าทอไรเดอร์ผ่านทางโทรศัพท์ และข่มขู่ว่าจะดักทำร้ายร่างกายหากมาส่งช้า',
        evidenceSummary: '🎙️ บันทึกเสียงการสนทนาข่มขู่ + แคปภาพข้อความในแชทแอป',
        status: 'investigating',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      ComplaintTicket(
        id: 'CMP-2026-083',
        orderNo: 'TB668509',
        reporterType: 'ไรเดอร์ (Driver)',
        reporterName: 'อดิศร ซิ่งไว (D008)',
        reporterPhone: '087-123-9988',
        accusedCustomerId: 'C012',
        accusedCustomerName: 'วรพล นามสมมุติ',
        accusedCustomerPhone: '084-222-1100',
        category: 'สร้างออเดอร์ปลอม / แกล้งสั่ง (Fake Orders)',
        severity: 'high',
        description: 'สั่งสินค้าแล้วกดยกเลิกตอนไรเดอร์ขับไปถึงจุดรับของหน้าร้าน 4 ครั้งต่อเนื่อง สร้างความเสียหายแก่ไรเดอร์และร้านค้า',
        evidenceSummary: '📑 ประวัติ Log คำสั่งซื้อและบันทึกเวลา GPS ไรเดอร์ถึงจุดเกิดเหตุ',
        status: 'action_taken',
        actionTakenNotes: 'แอดมินดำเนินการระงับบัญชีถาวร (Permanent Ban) และขึ้นบัญชีดำเบอร์โทรศัพท์เรียบร้อย',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        resolvedAt: DateTime.now().subtract(const Duration(hours: 18)),
      ),
      ComplaintTicket(
        id: 'CMP-2026-084',
        orderNo: 'TB668505',
        reporterType: 'ไรเดอร์ (Driver)',
        reporterName: 'อำนาจ ส่งทั่วไทย (D009)',
        reporterPhone: '086-456-7890',
        accusedCustomerId: 'C010',
        accusedCustomerName: 'เอกราช ก้องเกียรติ',
        accusedCustomerPhone: '082-890-1234',
        category: 'เปลี่ยนจุดส่งไกลเกินจริงโดยไม่จ่ายส่วนต่าง',
        severity: 'medium',
        description: 'ปลายทางเดิมมีนบุรี แต่สั่งให้ไปส่งพระราม 3 แล้วปฏิเสธจ่ายค่าส่วนต่างระยะทางเพิ่ม 24 กม.',
        evidenceSummary: '📍 พิกัด GPS จุดส่งจริงเทียบกับจุดที่ปักในระบบ',
        status: 'action_taken',
        actionTakenNotes: 'ตักเตือนลูกค้า (Strike 1) และหักเงินชดเชยค่าส่วนต่างให้ไรเดอร์แล้ว',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        resolvedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Customer Management & Suspension Actions
  void suspendCustomer(String customerId, String reason, String duration) {
    final c = customers.firstWhere((item) => item.id == customerId);
    c.isSuspended = true;
    c.suspensionReason = reason;
    c.suspendedAt = DateTime.now();
    c.suspensionDuration = duration;
    c.warningCount += 1;
    if (!c.incidentTags.contains(reason)) {
      c.incidentTags = [...c.incidentTags, reason];
    }
    addAuditLog('ระงับการใช้งานบัญชีลูกค้า ($duration)', '${c.name} (${c.phone}) เหตุผล: $reason');
    notifyListeners();
  }

  void unsuspendCustomer(String customerId) {
    final c = customers.firstWhere((item) => item.id == customerId);
    c.isSuspended = false;
    c.suspensionReason = null;
    c.suspendedAt = null;
    c.suspensionDuration = null;
    addAuditLog('ปลดระงับการใช้งานบัญชีลูกค้า', '${c.name} (${c.phone})');
    notifyListeners();
  }

  void issueCustomerWarning(String customerId, String reason) {
    final c = customers.firstWhere((item) => item.id == customerId);
    c.warningCount += 1;
    if (!c.incidentTags.contains(reason)) {
      c.incidentTags = [...c.incidentTags, reason];
    }
    addAuditLog('ออกใบเตือนพฤติกรรมลูกค้า (Strike ${c.warningCount})', '${c.name} (${c.phone}) - $reason');
    notifyListeners();
  }

  void updateComplaintStatus(String ticketId, String status, String notes) {
    final ticket = complaints.firstWhere((t) => t.id == ticketId);
    ticket.status = status;
    ticket.actionTakenNotes = notes;
    if (status == 'action_taken' || status == 'dismissed') {
      ticket.resolvedAt = DateTime.now();
    }
    addAuditLog('อัปเดตสถานะข้อร้องเรียน $ticketId', '$status ($notes)');
    notifyListeners();
  }


  void resolveSos(String driverId) {
    final d = trackingDrivers.firstWhere((item) => item.driverId == driverId);
    d.isSosAlert = false;
    d.status = TrackingStatus.available;
    d.sosReason = null;
    addAuditLog('คลี่คลายเหตุฉุกเฉิน SOS ของไรเดอร์', '${d.driverName} ($driverId)');
    notifyListeners();
  }

  void sendSafetyAlert(String driverId, String message) {
    final d = trackingDrivers.firstWhere((item) => item.driverId == driverId);
    addAuditLog('ส่งข้อความแจ้งเตือนความปลอดภัยให้ไรเดอร์', '${d.driverName}: $message');
    notifyListeners();
  }

  void assignOrderToDriver(String driverId, String orderNo) {
    final d = trackingDrivers.firstWhere((item) => item.driverId == driverId);
    final o = orders.firstWhere((item) => item.orderNo == orderNo);
    d.activeOrderNo = orderNo;
    d.customerName = o.customerName;
    d.customerPhone = o.customerPhone;
    d.pickupAddress = o.pickupAddress;
    d.dropoffAddress = o.dropoffAddress;
    d.status = TrackingStatus.arriving;
    d.etaMinutes = 10;
    d.distanceRemainingKm = o.distanceKm;
    d.waypoints = [
      TrackingWaypoint(title: 'มอบหมายงานใหม่โดยแอดมิน', address: 'ศูนย์ควบคุม HQ', time: 'เมื่อสักครู่', isCompleted: true),
      TrackingWaypoint(title: 'กำลังมุ่งหน้าจุดรับ', address: o.pickupAddress, time: 'ประมาณ 10 นาที', isCurrent: true),
      TrackingWaypoint(title: 'จุดส่งมอบปลายทาง', address: o.dropoffAddress, time: 'กำลังคำนวณ'),
    ];
    o.status = AdminOrderStatus.accepted;
    addAuditLog('จัดสรรคำสั่งซื้อให้ไรเดอร์แบบเจาะจง', '$orderNo -> ${d.driverName}');
    notifyListeners();
  }

  void simulateGpsMovement() {
    final random = Random();
    pin1Top = (pin1Top + (random.nextDouble() * 30 - 15)).clamp(50.0, 350.0);
    pin1Left = (pin1Left + (random.nextDouble() * 30 - 15)).clamp(50.0, 500.0);
    pin2Top = (pin2Top + (random.nextDouble() * 30 - 15)).clamp(50.0, 350.0);
    pin2Left = (pin2Left + (random.nextDouble() * 30 - 15)).clamp(50.0, 500.0);
    pin3Top = (pin3Top + (random.nextDouble() * 30 - 15)).clamp(50.0, 350.0);
    pin3Left = (pin3Left + (random.nextDouble() * 30 - 15)).clamp(50.0, 500.0);
    pin4Top = (pin4Top + (random.nextDouble() * 30 - 15)).clamp(50.0, 350.0);
    pin4Left = (pin4Left + (random.nextDouble() * 30 - 15)).clamp(50.0, 500.0);
    pin5Top = (pin5Top + (random.nextDouble() * 30 - 15)).clamp(50.0, 350.0);
    pin5Left = (pin5Left + (random.nextDouble() * 30 - 15)).clamp(50.0, 500.0);

    for (var d in trackingDrivers) {
      if (d.status != TrackingStatus.offline && d.status != TrackingStatus.sos) {
        d.topRatio = (d.topRatio + (random.nextDouble() * 0.04 - 0.02)).clamp(0.1, 0.9);
        d.leftRatio = (d.leftRatio + (random.nextDouble() * 0.04 - 0.02)).clamp(0.1, 0.9);
        if (d.status == TrackingStatus.inTransit || d.status == TrackingStatus.arriving) {
          d.speedKmH = (35 + random.nextInt(35)).toDouble();
          if (d.etaMinutes > 1 && random.nextBool()) {
            d.etaMinutes -= 1;
          }
          if (d.distanceRemainingKm > 0.3) {
            d.distanceRemainingKm = double.parse((d.distanceRemainingKm - 0.2).toStringAsFixed(1));
          }
        }
        d.lastPing = DateTime.now();
      }
    }
    notifyListeners();
  }

  void addAuditLog(String action, String target) {
    auditLogs.insert(
      0,
      AuditLogItem(
        id: 'LOG${(auditLogs.length + 1).toString().padLeft(2, '0')}',
        adminName: currentAdmin.name,
        action: action,
        target: target,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void addCustomer(String name, String email, String phone, String address, {bool isVip = false}) {
    final newId = 'C${(customers.length + 1).toString().padLeft(3, '0')}';
    customers.insert(
      0,
      CustomerModel(
        id: newId,
        name: name,
        email: email,
        phone: phone,
        address: address,
        totalOrders: 0,
        totalSpent: 0.0,
        rating: 5.0,
        isVip: isVip,
        createdAt: DateTime.now(),
      ),
    );
    addAuditLog('เพิ่มข้อมูลลูกค้าใหม่', '$name ($phone)');
    notifyListeners();
  }

  void deleteCustomer(String id) {
    final c = customers.firstWhere((item) => item.id == id);
    customers.removeWhere((item) => item.id == id);
    addAuditLog('ลบข้อมูลลูกค้าออกจากระบบ', '${c.name} ($id)');
    notifyListeners();
  }


  void addPromoVoucher(PromoVoucher voucher) {
    promoVouchers.insert(0, voucher);
    addAuditLog('สร้างโค้ดโปรโมชั่นใหม่', voucher.code);
    notifyListeners();
  }

  void togglePromoStatus(String code) {
    final v = promoVouchers.firstWhere((p) => p.code == code);
    final idx = promoVouchers.indexOf(v);
    promoVouchers[idx] = PromoVoucher(
      code: v.code,
      discountAmount: v.discountAmount,
      discountType: v.discountType,
      usageCount: v.usageCount,
      maxUsage: v.maxUsage,
      isActive: !v.isActive,
    );
    addAuditLog('เปลี่ยนสถานะโค้ดโปรโมชั่น', '$code -> ${!v.isActive ? "Active" : "Disabled"}');
    notifyListeners();
  }

  void sendMessage(String roomId, String text) {
    if (text.trim().isEmpty) return;
    final room = chatRooms.firstWhere((r) => r.id == roomId);
    room.messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: currentAdmin.name,
        text: text.trim(),
        timestamp: DateTime.now(),
        isFromMe: true,
      ),
    );
    notifyListeners();

    // Auto simulated reply after 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (room.category == ChatCategory.team) {
        room.messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sender: 'ผู้จัดการ วรวุฒิ',
            text: 'รับทราบข้อความครับ ทีมงานพร้อมดำเนินการต่อทันที 👍',
            timestamp: DateTime.now(),
            isFromMe: false,
          ),
        );
      } else if (room.category == ChatCategory.driver) {
        room.messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sender: room.name.split(' ')[0],
            text: 'รับทราบครับแอดมิน กำลังเร่งนำส่งตามมาตรฐานครับ ขอบคุณครับ 🙏',
            timestamp: DateTime.now(),
            isFromMe: false,
          ),
        );
      } else if (room.category == ChatCategory.emergency) {
        room.messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sender: 'ศูนย์ฉุกเฉิน 191/กู้ภัย',
            text: 'ประสานงานเจ้าหน้าที่เรียบร้อยแล้ว กำลังเดินทางเข้าตรวจสอบจุดเกิดเหตุครับ 🚑',
            timestamp: DateTime.now(),
            isFromMe: false,
          ),
        );
      } else {
        room.messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sender: room.name.split(' ')[0],
            text: 'ขอบคุณแอดมินมากครับที่ช่วยดูแลให้อย่างรวดเร็วครับ ⭐⭐⭐⭐⭐',
            timestamp: DateTime.now(),
            isFromMe: false,
          ),
        );
      }
      notifyListeners();
    });
  }

  void clearRoomMessages(String roomId) {
    final room = chatRooms.firstWhere((r) => r.id == roomId);
    room.messages.clear();
    notifyListeners();
  }

  void markRoomAsRead(String roomId) {
    final room = chatRooms.firstWhere((r) => r.id == roomId);
    room.unreadCount = 0;
    notifyListeners();
  }

  // Driver Actions
  void approveDriver(String id) {
    final d = drivers.firstWhere((d) => d.id == id);
    d.status = DriverVerificationStatus.approved;
    addAuditLog('อนุมัติการสมัครไรเดอร์', '${d.fullName} (${d.plate})');
    notifyListeners();
  }

  void rejectDriver(String id) {
    final d = drivers.firstWhere((d) => d.id == id);
    d.status = DriverVerificationStatus.rejected;
    addAuditLog('ปฏิเสธการสมัครไรเดอร์', d.fullName);
    notifyListeners();
  }

  void suspendDriver(String id) {
    final d = drivers.firstWhere((d) => d.id == id);
    d.status = DriverVerificationStatus.suspended;
    d.isOnline = false;
    addAuditLog('ระงับการทำงานไรเดอร์', d.fullName);
    notifyListeners();
  }

  void reinstateDriver(String id) {
    final d = drivers.firstWhere((d) => d.id == id);
    d.status = DriverVerificationStatus.approved;
    addAuditLog('คืนสถานะการทำงานไรเดอร์', d.fullName);
    notifyListeners();
  }

  void addDriver(DriverAdminModel driver) {
    drivers.insert(0, driver);
    addAuditLog('เพิ่มไรเดอร์ใหม่ในระบบ', '${driver.fullName} (${driver.vehicleType})');
    notifyListeners();
  }

  // Customer Actions
  void toggleCustomerSuspend(String id) {
    final c = customers.firstWhere((c) => c.id == id);
    c.isSuspended = !c.isSuspended;
    addAuditLog(c.isSuspended ? 'ระงับบัญชีลูกค้า' : 'ปลดระงับบัญชีลูกค้า', c.name);
    notifyListeners();
  }

  // Order Actions
  void updateOrderStatus(String orderNo, AdminOrderStatus status) {
    final o = orders.firstWhere((o) => o.orderNo == orderNo);
    o.status = status;
    addAuditLog('อัปเดตสถานะคำสั่งซื้อ', '$orderNo -> ${status.name}');
    notifyListeners();
  }

  void addOrder(AdminOrderModel order) {
    orders.insert(0, order);
    addAuditLog('สร้างคำสั่งซื้อใหม่', '${order.orderNo} (฿${order.amount.toInt()})');
    notifyListeners();
  }

  void cancelOrder(String orderNo) {
    final o = orders.firstWhere((o) => o.orderNo == orderNo);
    o.status = AdminOrderStatus.cancelled;
    addAuditLog('ยกเลิกคำสั่งซื้อ', orderNo);
    notifyListeners();
  }

  // Finance Actions
  void approveWithdrawal(String id) {
    final w = withdrawals.firstWhere((w) => w.id == id);
    w.status = 'approved';
    addAuditLog('อนุมัติการถอนเงินไรเดอร์', '${w.driverName} ฿${w.amount.toInt()}');
    notifyListeners();
  }

  void rejectWithdrawal(String id) {
    final w = withdrawals.firstWhere((w) => w.id == id);
    w.status = 'rejected';
    addAuditLog('ปฏิเสธคำขอถอนเงิน', '${w.driverName} ฿${w.amount.toInt()}');
    notifyListeners();
  }

  // Admin Actions
  void addAdmin(String name, String email, AdminRole role, String department) {
    final newId = 'A${(admins.length + 1).toString().padLeft(3, '0')}';
    admins.add(AdminUserModel(
      id: newId,
      name: name,
      email: email,
      role: role,
      department: department,
      lastLogin: DateTime.now(),
    ));
    addAuditLog('เพิ่มผู้ดูแลระบบใหม่', '$name (${role.name})');
    notifyListeners();
  }

  void updateAdmin(String id, String name, String email, AdminRole role, String department, bool isActive) {
    final a = admins.firstWhere((a) => a.id == id);
    admins[admins.indexOf(a)] = AdminUserModel(
      id: id,
      name: name,
      email: email,
      role: role,
      department: department,
      isActive: isActive,
      lastLogin: a.lastLogin,
    );
    addAuditLog('แก้ไขข้อมูลผู้ดูแลระบบ', name);
    notifyListeners();
  }

  void deleteAdmin(String id) {
    final a = admins.firstWhere((a) => a.id == id);
    admins.removeWhere((item) => item.id == id);
    addAuditLog('ลบบัญชีผู้ดูแลระบบ', a.name);
    notifyListeners();
  }
}
