import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_info.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../providers/app_providers.dart';


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

  late final NetworkInfo _networkInfo;


  @override
  SplashState build() {

    _networkInfo = ref.watch(networkInfoProvider);

    return const SplashState();

  }



  Future<void> initialize() async {


    // แสดง Splash Logo
    await Future.delayed(
      const Duration(milliseconds: 1000),
    );


    // Check Internet
    state = state.copyWith(
      status: SplashStatus.checkingInternet,
      message: 'กำลังตรวจสอบการเชื่อมต่อ...',
      progress: 0.25,
    );


    await Future.delayed(
      const Duration(milliseconds: 400),
    );


    final isConnected =
        await _networkInfo.isConnected;



    if (!isConnected) {

      state = state.copyWith(
        status: SplashStatus.noInternet,
        message: 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
        progress: 0.25,
      );

      return;

    }



    // Load Config
    state = state.copyWith(
      status: SplashStatus.loadingConfig,
      message: 'กำลังโหลดการตั้งค่า...',
      progress: 0.55,
    );


    await Future.delayed(
      const Duration(milliseconds: 500),
    );



    // Check Token
    state = state.copyWith(
      status: SplashStatus.checkingToken,
      message: 'กำลังตรวจสอบสิทธิ์...',
      progress: 0.80,
    );


    await Future.delayed(
      const Duration(milliseconds: 400),
    );



    final hasToken =
        await SecureStorage.hasAccessToken();



    // Navigate
    state = state.copyWith(
      progress: 1.0,

      status: hasToken
          ? SplashStatus.navigateToHome
          : SplashStatus.navigateToLogin,

      message: hasToken
          ? 'ยินดีต้อนรับ!'
          : 'กรุณาเข้าสู่ระบบ',
    );

  }




  Future<void> retry() async {

    state = const SplashState();

    await initialize();

  }

}


// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final splashProvider =
    NotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);