import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TwoFactorNotifier extends Notifier<bool> {
  static const String _prefKey = 'app_2fa_enabled';

  @override
  bool build() {
    _loadPreference();
    return false;
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_prefKey) ?? false;
    } catch (_) {
      state = false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, enabled);
    } catch (_) {}
  }
}

final twoFactorProvider = NotifierProvider<TwoFactorNotifier, bool>(() {
  return TwoFactorNotifier();
});
