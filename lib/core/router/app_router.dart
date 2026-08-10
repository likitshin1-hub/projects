import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';

import '../../features/home/screens/home_screen.dart';

import '../../features/booking/screens/booking_screen.dart';
import '../../features/booking/screens/tracking_screen.dart';

import '../../features/history/screens/delivery_history_page.dart';

import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/rewards/screens/rewards_screen.dart';
import '../../features/coupons/screens/coupons_screen.dart';
import '../../features/coupons/screens/claim_coupons_screen.dart';
import '../../features/notifications/screens/notification_detail_screen.dart';
import '../../features/notifications/screens/notifications_list_screen.dart';
import '../../features/chat/screens/chat_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.booking,
      builder: (context, state) {
        final vehicle = state.extra as String?;
        return BookingScreen(initialVehicleType: vehicle);
      },
    ),
    GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => const DeliveryHistoryPage(),
    ),
    GoRoute(
      path: '${AppRoutes.tracking}/:id',
      builder: (context, state) {
        final bookingId = state.pathParameters['id'] ?? '';
        return TrackingScreen(bookingId: bookingId);
      },
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
      path: AppRoutes.rewards,
      builder: (context, state) => const RewardsScreen(),
    ),
    GoRoute(
      path: AppRoutes.coupons,
      builder: (context, state) => const CouponsScreen(),
    ),
    GoRoute(
      path: AppRoutes.claimCoupons,
      builder: (context, state) => const ClaimCouponsScreen(),
    ),
    GoRoute(
      path: AppRoutes.notification,
      builder: (context, state) => const NotificationsListScreen(),
    ),
    GoRoute(
      path: AppRoutes.notificationDetail,
      builder: (context, state) => const NotificationDetailScreen(),
    ),
    GoRoute(
      path: AppRoutes.chatDetail,
      builder: (context, state) => const ChatDetailScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);