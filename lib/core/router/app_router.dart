import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';

// Splash
import '../../features/splash/screens/splash_screen.dart';

// Auth
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';

// Home
import '../../features/home/screens/home_screen.dart';

// Booking
import '../../features/booking/screens/booking_screen.dart';
import '../../features/booking/screens/tracking_screen.dart';

// History
import '../../features/history/screens/delivery_history_page.dart';

// Profile
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';

// Rewards
import '../../features/rewards/screens/rewards_screen.dart';

// Coupons
import '../../features/coupons/screens/coupons_screen.dart';
import '../../features/coupons/screens/claim_coupons_screen.dart';

// Notifications
import '../../features/notifications/screens/notification_detail_screen.dart';
import '../../features/notifications/screens/notifications_list_screen.dart';

// Chat
import '../../features/chat/screens/chat_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
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

        return BookingScreen(
          initialVehicleType: vehicle,
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
      path: '${AppRoutes.tracking}/:id',
      builder: (context, state) {
        final bookingId = state.pathParameters['id'] ?? '';

        return TrackingScreen(
          bookingId: bookingId,
        );
      },
    ),

    // Profile
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),

    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),

    // Rewards
    GoRoute(
      path: AppRoutes.rewards,
      builder: (context, state) => const RewardsScreen(),
    ),

    // Coupons
    GoRoute(
      path: AppRoutes.coupons,
      builder: (context, state) => const CouponsScreen(),
    ),

    GoRoute(
      path: AppRoutes.claimCoupons,
      builder: (context, state) => const ClaimCouponsScreen(),
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

    // Chat
    GoRoute(
      path: AppRoutes.chatDetail,
      builder: (context, state) => const ChatDetailScreen(),
    ),

    // Settings
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);