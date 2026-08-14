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

  static const String verification = '/verify';

  static const String successVerification = '/verify-success';

  static const String terms = '/terms';

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
  // Driver / Partner
  // =========================

  static const String driver = '/driver';

  static const String partner = '/partner';

  static const String partnerLanding = '/partner-landing';

  static const String registerPartner = '/register-partner';

  static const String partnerSuccess = '/partner-success';

  static const String driverJobs = '/driver/jobs';

  static const String jobDetail = '/driver/job-detail';

  // =========================
  // Tracking & Booking
  // =========================

  static const String tracking = '/tracking';
  
  static const String trackingDetail = '/tracking/detail';

  static const String searchingRider = '/searching-rider';
  static const String payment = '/payment';
  
  static const String deliverySuccess = '/delivery-success';
  
  static const String cancelOrder = '/cancel-order';

  // =========================
  // Chat & Call
  // =========================

  static const String chat = '/chat';
  
  static const String call = '/call';

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

  static const String coupons = '/coupons';

  static const String claimCoupons = '/coupons/claim';

  static const String rewards = '/rewards';

  static const String help = '/help';

  static const String chatDetail = '/chat/detail';

  // =========================
  // Settings
  // =========================

  static const String settings = '/settings';
}
