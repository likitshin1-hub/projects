class AppRoutes {
  AppRoutes._();

  // =========================
  // Initial
  // =========================

  static const String splash = '/';

  // =========================
  // Authentication
  // =========================

  static const String login = '/login';

  static const String register = '/register';

  static const String forgotPassword = '/forgot-password';

  // =========================
  // Main
  // =========================

  static const String home = '/home';

  // =========================
  // Booking & History
  // =========================

  static const String booking = '/booking';

  static const String history = '/history';

  // =========================
  // Profile
  // =========================

  static const String profile = '/profile';

  static const String editProfile = '/profile/edit';

  // =========================
  // Order
  // =========================

  static const String orders = '/orders';

  static const String orderDetail = '/orders/detail';

  // =========================
  // Driver
  // =========================

  static const String driver = '/driver';

  static const String driverJobs = '/driver/jobs';

  static const String jobDetail = '/driver/job-detail';

  // =========================
  // Tracking
  // =========================

  static const String tracking = '/tracking';

  // =========================
  // Wallet
  // =========================

  static const String wallet = '/wallet';

  static const String withdraw = '/wallet/withdraw';

  static const String transactionHistory = '/wallet/history';

  // =========================
  // Notification
  // =========================

  static const String notification = '/notifications';
  static const String notificationDetail = '/notifications/detail';

  static const String settings = '/settings';

  // =========================
  // Chat
  // =========================
  static const String chatDetail = '/chat/detail';

  // =========================
  // Rewards
  // =========================

  static const String rewards = '/rewards';

  // =========================
  // Coupons
  // =========================

  static const String coupons = '/coupons';

  // =========================
  // Claim Coupons
  // =========================

  static const String claimCoupons = '/claim-coupons';

  // =========================
  // Help & Support
  // =========================

  static const String help = '/help';
}
