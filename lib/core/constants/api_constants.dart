class ApiConstants {
  ApiConstants._();

  // Localhost Emulator
  static const baseUrl = "http://10.0.2.2:8000/api";

  // ถ้าใช้เครื่องจริง
  // static const baseUrl = "http://192.168.1.100:8000/api";

  // Authentication
  static const login = "/login";
  static const register = "/register";
  static const logout = "/logout";

  // User
  static const profile = "/profile";

  // Orders
  static const orders = "/orders";
  static const acceptOrder = "/orders/accept";
  static const cancelOrder = "/orders/cancel";

  // Driver
  static const driver = "/driver";
  static const wallet = "/wallet";
  static const withdraw = "/withdraw";

  // Notification
  static const notification = "/notifications";
}