import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/admin_data_service.dart';
import 'theme/admin_theme.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th', null);
  await initializeDateFormatting('en', null);
  runApp(const TBMoveHubAdminApp());
}

class TBMoveHubAdminApp extends StatefulWidget {
  const TBMoveHubAdminApp({super.key});

  @override
  State<TBMoveHubAdminApp> createState() => _TBMoveHubAdminAppState();
}

class _TBMoveHubAdminAppState extends State<TBMoveHubAdminApp> {
  final AdminDataService _dataService = AdminDataService();

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _dataService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBMoveHub Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.lightTheme,
      darkTheme: AdminTheme.darkTheme,
      themeMode: _dataService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: AdminLoginScreen(dataService: _dataService),
    );
  }
}
