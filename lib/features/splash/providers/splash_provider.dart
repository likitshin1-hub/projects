import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage.dart';

// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────

enum SplashStatus {
  initial,
  checkingInternet,
  loadingConfig,
  checkingToken,
  navigateToHome,
  navigateToLogin,
  noInternet,
  error,
}

class SplashState {
  final SplashStatus status;
  final String message;
  final double progress;
  final String? errorMessage;

  const SplashState({
    this.status = SplashStatus.initial,
    this.message = 'กำลังเริ่มต้น...',
    this.progress = 0.0,
    this.errorMessage,
  });

  SplashState copyWith({
    SplashStatus? status,
    String? message,
    double? progress,
    String? errorMessage,
  }) {
    return SplashState(
      status: status ?? this.status,
      message: message ?? this.message,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isNavigating =>
      status == SplashStatus.navigateToHome ||
      status == SplashStatus.navigateToLogin;
}

// ─────────────────────────────────────────────
// Notifier (Riverpod 3)
// ─────────────────────────────────────────────

class SplashNotifier extends Notifier<SplashState> {
  @override
  SplashState build() {
    return const SplashState();
  }

  Future<void> initialize() async {
    try {
      state = state.copyWith(
        status: SplashStatus.checkingInternet,
        message: 'กำลังเริ่มต้นระบบ...',
        progress: 0.3,
      );

      await Future.delayed(const Duration(milliseconds: 600));

      state = state.copyWith(
        status: SplashStatus.loadingConfig,
        message: 'กำลังโหลดข้อมูล...',
        progress: 0.7,
      );

      await Future.delayed(const Duration(milliseconds: 600));

      bool hasToken = false;
      try {
        hasToken = await SecureStorage.hasAccessToken();
      } catch (_) {}

      state = state.copyWith(
        progress: 1.0,
        status: hasToken
            ? SplashStatus.navigateToHome
            : SplashStatus.navigateToLogin,
        message: hasToken ? 'ยินดีต้อนรับ!' : 'กรุณาเข้าสู่ระบบ',
      );
    } catch (e) {
      state = state.copyWith(
        progress: 1.0,
        status: SplashStatus.navigateToLogin,
        message: 'กรุณาเข้าสู่ระบบ',
      );
    }
  }

  Future<void> retry() async {
    state = const SplashState();
    await initialize();
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final splashProvider = NotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);
