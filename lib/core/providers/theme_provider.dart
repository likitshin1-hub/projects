import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeKey = 'app_is_dark_mode';

class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadSavedTheme();
    // Default is Light Mode (false) as requested
    return false;
  }

  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey);
      if (isDark != null) {
        state = isDark;
      }
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    state = !state;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, state);
    } catch (_) {}
  }

  Future<void> setThemeMode({required bool isDark}) async {
    state = isDark;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDark);
    } catch (_) {}
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, bool>(
  ThemeNotifier.new,
);
