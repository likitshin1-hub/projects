class ApiConstants {
  ApiConstants._();

  // =========================
  // Base Configuration
  // =========================

  static const String baseUrl = "http://10.0.2.2:8000/api";

  static const String apiVersion = "/v1";

  static const String contentType = "application/json";

  // =========================
  // Timeout
  // =========================

  static const Duration connectTimeout = Duration(seconds: 30);

  static const Duration receiveTimeout = Duration(seconds: 30);

  static const Duration sendTimeout = Duration(seconds: 30);

  // =========================
  // Authentication
  // =========================

  static const String login = "/login";

  static const String register = "/register";

  static const String logout = "/logout";

  // =========================
  // User
  // =========================

  static const String profile = "/profile";

  static const String updateProfile = "/profile/update";

  // =========================
  // Food / Restaurant
  // =========================

  static const String restaurants = "/restaurants";

  static const String menu = "/menu";

  // =========================
  // Orders
  // =========================

  static const String orders = "/orders";

  static const String orderDetail = "/orders/detail";

  static const String createOrder = "/orders/create";

  static const String acceptOrder = "/orders/accept";

  static const String cancelOrder = "/orders/cancel";

  // =========================
  // Driver
  // =========================

  static const String driver = "/driver";

  static const String driverJobs = "/driver/jobs";

  static const String acceptJob = "/driver/jobs/accept";

  // =========================
  // Tracking
  // =========================

  static const String tracking = "/tracking";

  static const String driverLocation = "/tracking/location";

  // =========================
  // Wallet
  // =========================

  static const String wallet = "/wallet";

  static const String withdraw = "/withdraw";

  static const String transactions = "/transactions";

  // =========================
  // Notification
  // =========================

  static const String notification = "/notifications";
}
