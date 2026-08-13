import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { th, en }

class LanguageNotifier extends Notifier<AppLanguage> {
  static const String _prefKey = 'app_language_code';

  @override
  AppLanguage build() {
    _loadLanguagePreference();
    return AppLanguage.th;
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString(_prefKey) ?? 'th';
      state = langCode == 'en' ? AppLanguage.en : AppLanguage.th;
    } catch (_) {
      state = AppLanguage.th;
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language == AppLanguage.en ? 'en' : 'th');
    } catch (_) {}
  }

  void toggleLanguage() {
    setLanguage(state == AppLanguage.th ? AppLanguage.en : AppLanguage.th);
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(() {
  return LanguageNotifier();
});
