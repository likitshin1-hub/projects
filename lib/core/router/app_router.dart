import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/booking/screens/booking_screen.dart';
import '../../features/booking/screens/tracking_screen.dart';

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
      path: '${AppRoutes.tracking}/:id',
      builder: (context, state) {
        final bookingId = state.pathParameters['id'] ?? '';
        return TrackingScreen(bookingId: bookingId);
      },
    ),
  ],
);
