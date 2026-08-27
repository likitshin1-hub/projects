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

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 48),
                const SizedBox(height: 12),
                const Text(
                  '⚠️ Flutter Web Rendering Issue Detected:',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    details.exceptionAsString(),
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  details.stack?.toString() ?? '',
                  style: const TextStyle(color: Colors.white60, fontSize: 10, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

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
