class AppRoutes {
  AppRoutes._();

  static const splash = "/";
  static const onboarding = "/onboarding";

  // Auth
  static const login = "/login";
  static const register = "/register";
  static const forgotPassword = "/forgot-password";

  // Home
  static const home = "/home";

  // Customer
  static const createOrder = "/create-order";
  static const tracking = "/tracking";
  static const orderHistory = "/order-history";

  // Driver
  static const driverHome = "/driver-home";
  static const jobDetail = "/job-detail";
  static const wallet = "/wallet";
  static const withdraw = "/withdraw";

  // Shared
  static const profile = "/profile";
  static const settings = "/settings";
  static const notification = "/notification";
}