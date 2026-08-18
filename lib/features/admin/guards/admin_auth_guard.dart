import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';

class AdminAuthGuard {
  static bool isAuthenticated = true;
  static String currentRole = 'superAdmin'; // superAdmin, admin, staff

  /// Check route guard for /admin path
  static String? guard(BuildContext context, GoRouterState state) {
    final isGoingToAdmin = state.matchedLocation.startsWith('/admin') && state.matchedLocation != AppRoutes.adminLogin;
    
    if (isGoingToAdmin && !isAuthenticated) {
      return AppRoutes.adminLogin;
    }

    return null;
  }
}
