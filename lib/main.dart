import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  if (kIsWeb) {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: '1020611840710101',
      cookie: true,
      xfbml: true,
      version: 'v15.0',
    );
  }

  runApp(
    const ProviderScope(
      child: TBMoveHubApp(),
    ),
  );
}

class TBMoveHubApp extends StatelessWidget {
  const TBMoveHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}