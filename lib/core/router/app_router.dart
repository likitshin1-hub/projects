import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';

// Splash
import '../../features/splash/screens/splash_screen.dart';

// Auth
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/verification_screen.dart';
import '../../features/auth/screens/success_screen.dart';
import '../../features/auth/screens/terms_screen.dart';

// Home
import '../../features/home/screens/home_screen.dart';

// Booking
import '../../features/booking/screens/booking_screen.dart';
import '../../features/booking/screens/searching_rider_screen.dart';
import '../../features/booking/screens/tracking_screen.dart';
import '../../features/booking/screens/tracking_detail_screen.dart';
import '../../features/booking/screens/delivery_success_screen.dart';
import '../../features/booking/screens/cancel_order_screen.dart';
import '../../features/booking/screens/payment_screen.dart';

// Chat
import '../../features/chat/screens/chat_screen.dart';
import '../../features/chat/screens/call_screen.dart';

// History
import '../../features/history/screens/delivery_history_page.dart';

// Profile
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/change_password_screen.dart';
import '../../features/profile/screens/legal_content_screen.dart';

// Coupons & Rewards
import '../../features/coupons/screens/coupons_screen.dart';
import '../../features/coupons/screens/claim_coupons_screen.dart';
import '../../features/rewards/screens/rewards_screen.dart';

// Help
import '../../features/help/screens/help_screen.dart';

// Notifications
import '../../features/notifications/screens/notifications_list_screen.dart';
import '../../features/notifications/screens/notification_detail_screen.dart';

// Partner / Driver
import '../../features/partner/screens/partner_screen.dart';
import '../../features/partner/screens/driver_partner_landing_screen.dart';
import '../../features/partner/screens/register_partner_screen.dart';
import '../../features/partner/screens/driver_register_success_screen.dart';

// Admin
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_login_screen.dart';
import '../../features/admin/guards/admin_auth_guard.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: AdminAuthGuard.guard,
  routes: [
    // Splash
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Auth
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.verification,
      builder: (context, state) => const VerificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.successVerification,
      builder: (context, state) => const SuccessScreen(),
    ),
    GoRoute(
      path: AppRoutes.terms,
      builder: (context, state) => const TermsScreen(),
    ),

    // Home
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),

    // Booking
    GoRoute(
      path: AppRoutes.booking,
      builder: (context, state) {
        final vehicle = state.extra as String?;
        final stepStr = state.uri.queryParameters['step'];
        final step = stepStr != null ? int.tryParse(stepStr) : null;
        return BookingScreen(
          initialVehicleType: vehicle,
          initialStep: step,
        );
      },
    ),

    // History
    GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => const DeliveryHistoryPage(),
    ),

    // Tracking
    GoRoute(
      path: AppRoutes.tracking,
      builder: (context, state) => const TrackingScreen(bookingId: 'TB668511'),
    ),
    GoRoute(
      path: '${AppRoutes.tracking}/:id',
      builder: (context, state) {
        final bookingId = state.pathParameters['id'] ?? 'TB668511';
        return TrackingScreen(
          bookingId: bookingId,
        );
      },
    ),
    GoRoute(
      path: '${AppRoutes.trackingDetail}/:id',
      builder: (context, state) {
        final bookingId = state.pathParameters['id'] ?? '';
        return TrackingDetailScreen(bookingId: bookingId);
      },
    ),
    GoRoute(
      path: AppRoutes.searchingRider,
      builder: (context, state) => const SearchingRiderScreen(),
    ),
    GoRoute(
      path: AppRoutes.payment,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final amount = extra['amount'] as double? ?? 0.0;
        return PaymentScreen(amount: amount);
      },
    ),
    GoRoute(
      path: AppRoutes.deliverySuccess,
      builder: (context, state) => const DeliverySuccessScreen(),
    ),
    GoRoute(
      path: AppRoutes.cancelOrder,
      builder: (context, state) => const CancelOrderScreen(),
    ),

    // Chat
    GoRoute(
      path: '${AppRoutes.chat}/:id',
      builder: (context, state) {
        final driverId = state.pathParameters['id'] ?? '';
        return ChatScreen(driverId: driverId);
      },
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) => const ChatScreen(driverId: 'support'),
    ),
    GoRoute(
      path: AppRoutes.chatDetail,
      builder: (context, state) => const ChatScreen(driverId: 'driver_somchai'),
    ),
    GoRoute(
      path: '${AppRoutes.call}/:id',
      builder: (context, state) {
        final driverId = state.pathParameters['id'] ?? '';
        return CallScreen(driverId: driverId);
      },
    ),

    // Profile & Settings
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.legal,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final isPrivacy = extra['isPrivacy'] as bool? ?? true;
        return LegalContentScreen(isPrivacy: isPrivacy);
      },
    ),

    // Coupons & Rewards
    GoRoute(
      path: AppRoutes.coupons,
      builder: (context, state) => const CouponsScreen(),
    ),
    GoRoute(
      path: AppRoutes.claimCoupons,
      builder: (context, state) => const ClaimCouponsScreen(),
    ),
    GoRoute(
      path: AppRoutes.rewards,
      builder: (context, state) => const RewardsScreen(),
    ),

    // Help
    GoRoute(
      path: AppRoutes.help,
      builder: (context, state) => const HelpScreen(),
    ),

    // Notifications
    GoRoute(
      path: AppRoutes.notification,
      builder: (context, state) => const NotificationsListScreen(),
    ),
    GoRoute(
      path: AppRoutes.notificationDetail,
      builder: (context, state) => const NotificationDetailScreen(),
    ),

    // Partner / Driver
    GoRoute(
      path: AppRoutes.driver,
      builder: (context, state) => const PartnerScreen(),
    ),
    GoRoute(
      path: AppRoutes.partner,
      builder: (context, state) => const PartnerScreen(),
    ),
    GoRoute(
      path: AppRoutes.partnerLanding,
      builder: (context, state) => const DriverPartnerLandingScreen(),
    ),
    GoRoute(
      path: AppRoutes.registerPartner,
      builder: (context, state) => const RegisterPartnerScreen(),
    ),
    GoRoute(
      path: AppRoutes.partnerSuccess,
      builder: (context, state) => const DriverRegisterSuccessScreen(),
    ),

    // Admin
    GoRoute(
      path: AppRoutes.admin,
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admiin',
      redirect: (context, state) => AppRoutes.admin,
    ),
    GoRoute(
      path: AppRoutes.adminLogin,
      builder: (context, state) => const AdminLoginScreen(),
    ),
  ],
);
