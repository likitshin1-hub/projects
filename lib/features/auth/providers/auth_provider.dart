import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

// ===== State =====

enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final UserModel? user;

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    UserModel? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

// ===== Notifier (Riverpod 3.x) =====

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = AuthRepository();
    return const AuthState();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _repository.login(email: email, password: password);
    if (result.isSuccess) {
      state = state.copyWith(status: AuthStatus.success);
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.error,
      );
    }
  }

  /// Login ด้วย Facebook SDK จริง
  Future<void> loginWithFacebook() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final userData = await FacebookAuth.instance.getUserData(
          fields: "id,name,email,picture.width(300)",
        );

        print("Facebook Access Token: ${accessToken.tokenString}");
        print(userData);

        final userModel = UserModel(
          id: userData["id"] ?? "",
          name: userData["name"] ?? "",
          email: userData["email"] ?? "",
          photoUrl: userData["picture"]?["data"]?["url"],
        );

        // เรียก API ของ Backend เพื่อบันทึกหรือตรวจสอบ token (หากมีระบบหลังบ้าน)
        await _repository.loginWithFacebook(
          accessToken: accessToken.tokenString,
        );

        state = AuthState(
          status: AuthStatus.success,
          user: userModel,
        );
      } else if (result.status == LoginStatus.cancelled) {
        print("ผู้ใช้ยกเลิกการเข้าสู่ระบบ");
        state = state.copyWith(
          status: AuthStatus.idle,
          errorMessage: "ผู้ใช้ยกเลิกการเข้าสู่ระบบ",
        );
      } else {
        print(result.message);
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: result.message,
        );
      }
    } catch (e) {
      print("Facebook Login Error: $e");
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Login ด้วย LINE
  /// ใน Mock Mode: ข้ามไปเลยโดยไม่ต้องเชื่อม SDK จริง
  /// เมื่อเชื่อม SDK จริง: เรียก LineSDK.instance.login() ก่อน แล้วส่ง accessToken มา
  Future<void> loginWithLine() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    
    // สำหรับ Web: เนื่องจาก LINE SDK สำหรับ Flutter ไม่สนับสนุน Web อย่างสมบูรณ์แบบ Native
    // จะใช้การจำลองการเข้าสู่ระบบเป็นหลักในการทดสอบ
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 1000));
      final userModel = UserModel(
        id: "mock_line_web_12345",
        name: "Test LINE User (Web)",
        email: "test.line.web@example.com",
        photoUrl: "https://picsum.photos/200",
      );
      state = AuthState(
        status: AuthStatus.success,
        user: userModel,
      );
      print("LINE Mock Web Login Success!");
      return;
    }

    const mockLineToken = 'mock_line_access_token';
    final result = await _repository.loginWithLine(
      accessToken: mockLineToken,
    );
    if (result.isSuccess) {
      state = state.copyWith(status: AuthStatus.success);
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.error,
      );
    }
  }

  Future<void> register({
    required String username,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _repository.register(
      username: username,
      phone: phone,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    if (result.isSuccess) {
      state = state.copyWith(status: AuthStatus.success);
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.error,
      );
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _repository.loginWithGoogle();
    
    if (result.isSuccess) {
      state = state.copyWith(status: AuthStatus.success);
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.error,
      );
    }
  }

  Future<void> logout() async {
    if (!kIsWeb) {
      await FacebookAuth.instance.logOut();
    }
    await _repository.logout();
    state = const AuthState(status: AuthStatus.idle, user: null);
  }

  Future<void> updateUser(UserModel user) async {
    state = state.copyWith(user: user);
  }

  void resetState() {
    state = const AuthState();
  }
}

// ===== Provider =====

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
