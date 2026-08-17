import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/services/push_notification_service.dart';

import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/language_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await PushNotificationService().initialize();
  } catch (e) {
    debugPrint("Firebase/PushNotification initialization failed: $e");
  }

  if (kIsWeb) {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: '1020611840710101',
      cookie: true,
      xfbml: true,
      version: 'v15.0',
    );
  }

  runApp(const ProviderScope(child: TBMoveHubApp()));
}

class TBMoveHubApp extends ConsumerWidget {
  const TBMoveHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(currentLang == AppLanguage.en ? 'en' : 'th'),
      supportedLocales: const [
        Locale('th', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
