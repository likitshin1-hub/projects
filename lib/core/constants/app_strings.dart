class AppStrings {
  AppStrings._();

  // =========================
  // App Information
  // =========================
  static const String appName = 'TBMoveHub';
  static const String appDescription = 'ระบบสั่งอาหารและบริการขนส่งครบวงจร';

  // =========================
  // General
  // =========================
  static const String ok = 'ตกลง';
  static const String cancel = 'ยกเลิก';
  static const String confirm = 'ยืนยัน';
  static const String save = 'บันทึก';
  static const String edit = 'แก้ไข';
  static const String delete = 'ลบ';
  static const String search = 'ค้นหา';
  static const String loading = 'กำลังโหลด...';
  static const String retry = 'ลองใหม่';

  // =========================
  // Authentication
  // =========================
  static const String login = 'เข้าสู่ระบบ';
  static const String logout = 'ออกจากระบบ';
  static const String register = 'สมัครสมาชิก';

  static const String email = 'อีเมล';
  static const String password = 'รหัสผ่าน';
  static const String confirmPassword = 'ยืนยันรหัสผ่าน';

  static const String username = 'ชื่อผู้ใช้';
  static const String phone = 'เบอร์โทรศัพท์';

  static const String forgotPassword = 'ลืมรหัสผ่าน?';

  // =========================
  // Home
  // =========================
  static const String home = 'หน้าหลัก';
  static const String welcome = 'ยินดีต้อนรับ';
  static const String recommended = 'เมนูแนะนำ';
  static const String popular = 'ยอดนิยม';

  // =========================
  // Order
  // =========================
  static const String order = 'คำสั่งซื้อ';
  static const String orders = 'รายการคำสั่งซื้อ';

  static const String orderDetail = 'รายละเอียดคำสั่งซื้อ';
  static const String orderHistory = 'ประวัติคำสั่งซื้อ';

  static const String pending = 'รอดำเนินการ';
  static const String accepted = 'รับงานแล้ว';
  static const String preparing = 'กำลังเตรียมอาหาร';
  static const String delivering = 'กำลังจัดส่ง';
  static const String completed = 'สำเร็จ';
  static const String cancelled = 'ยกเลิก';

  // =========================
  // Driver
  // =========================
  static const String driver = 'คนขับ';
  static const String driverProfile = 'โปรไฟล์คนขับ';

  static const String available = 'พร้อมรับงาน';
  static const String unavailable = 'ไม่พร้อมรับงาน';

  static const String acceptJob = 'รับงาน';
  static const String jobDetail = 'รายละเอียดงาน';

  // =========================
  // Tracking
  // =========================
  static const String tracking = 'ติดตามสถานะ';
  static const String liveTracking = 'ติดตามแบบเรียลไทม์';

  static const String pickupLocation = 'จุดรับสินค้า';
  static const String deliveryLocation = 'จุดส่งสินค้า';

  // =========================
  // Wallet
  // =========================
  static const String wallet = 'กระเป๋าเงิน';

  static const String balance = 'ยอดเงิน';
  static const String withdraw = 'ถอนเงิน';
  static const String transactionHistory = 'ประวัติรายการ';

  // =========================
  // Profile
  // =========================
  static const String profile = 'โปรไฟล์';
  static const String personalInformation = 'ข้อมูลส่วนตัว';
  static const String settings = 'ตั้งค่า';

  // =========================
  // Notification
  // =========================
  static const String notification = 'การแจ้งเตือน';
  static const String noNotification = 'ไม่มีการแจ้งเตือน';

  // =========================
  // Error Messages
  // =========================
  static const String error = 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';

  static const String networkError = 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้';

  static const String loginFailed = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';

  // =========================
  // Validation
  // =========================
  static const String requiredField = 'กรุณากรอกข้อมูล';

  static const String invalidEmail = 'รูปแบบอีเมลไม่ถูกต้อง';

  static const String passwordTooShort =
      'รหัสผ่านต้องมีความยาวอย่างน้อย 8 ตัวอักษร';
}
