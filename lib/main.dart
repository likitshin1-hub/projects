import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const TBMoveHubApp());
}

class TBMoveHubApp extends StatelessWidget {
  const TBMoveHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Scaffold(body: Center(child: Text('TBMoveHub'))),
    );
  }
}
