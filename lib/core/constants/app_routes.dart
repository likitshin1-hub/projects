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

  // =========================
  // Settings
  // =========================

  static const String settings = '/settings';
}
