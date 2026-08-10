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
import '../../features/home/screens/home_screen.dart';

// Booking
import '../../features/booking/screens/booking_screen.dart';
import '../../features/booking/screens/tracking_screen.dart';
import '../../features/booking/screens/tracking_detail_screen.dart';
import '../../features/booking/screens/delivery_success_screen.dart';
import '../../features/booking/screens/cancel_order_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/chat/screens/call_screen.dart';
import '../../features/history/screens/delivery_history_page.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // Splash
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Auth
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
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
    GoRoute(
      path: '${AppRoutes.trackingDetail}/:id',
      builder: (context, state) {
        final bookingId = state.pathParameters['id'] ?? '';
        return TrackingDetailScreen(bookingId: bookingId);
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
    GoRoute(
      path: '${AppRoutes.chat}/:id',
      builder: (context, state) {
        final driverId = state.pathParameters['id'] ?? '';
        return ChatScreen(driverId: driverId);
      },
    ),
    GoRoute(
      path: '${AppRoutes.call}/:id',
      builder: (context, state) {
        final driverId = state.pathParameters['id'] ?? '';
        return CallScreen(driverId: driverId);
      },
    ),
  ],
);

