import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

// =======================
// State
// =======================

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

  static const _keep = Object();

  AuthState copyWith({
    AuthStatus? status,
    Object? errorMessage = _keep,
    UserModel? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage == _keep
          ? this.errorMessage
          : errorMessage as String?,
      user: user ?? this.user,
    );
  }
}

// =======================
// Notifier
// =======================

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = AuthRepository();
    return const AuthState();
  }

  // =======================
  // Email Login
  // =======================

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );

    final result = await _repository.login(
      email: email,
      password: password,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        status: AuthStatus.success,
        user: UserModel(
          id: 'mock_123',
          name: 'กิตติพัฒน์ ราษฎร์นิยม',
          email: email,
          phone: '097-117-9446',
        ),
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.error,
      );
    }
  }

  // =======================
  // Update User
  // =======================

  void updateUser(UserModel updatedUser) {
    state = state.copyWith(user: updatedUser);
  }

  // =======================
  // Facebook Login
  // =======================

  Future<void> loginWithFacebook() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );

    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;

        final userData = await FacebookAuth.instance.getUserData(
          fields: 'id,name,email,picture.width(300)',
        );

        debugPrint('Facebook Token: ${accessToken.tokenString}');
        debugPrint(userData.toString());

        final userModel = UserModel(
          id: userData['id'] ?? '',
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          photoUrl: userData['picture']?['data']?['url'],
        );

        final apiResult = await _repository.loginWithFacebook(
          accessToken: accessToken.tokenString,
        );

        if (apiResult.isSuccess) {
          state = AuthState(
            status: AuthStatus.success,
            user: userModel,
          );
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: apiResult.error,
          );
        }
      } else if (result.status == LoginStatus.cancelled) {
        debugPrint('Facebook login cancelled');

        state = state.copyWith(
          status: AuthStatus.idle,
          errorMessage: 'ผู้ใช้ยกเลิกการเข้าสู่ระบบ',
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: result.message,
        );
      }
    } catch (e) {
      debugPrint('Facebook Login Error: $e');

      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // =======================
  // LINE Login
  // =======================

  Future<void> loginWithLine() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );

    if (kIsWeb) {
      await Future.delayed(const Duration(seconds: 1));

      final userModel = UserModel(
        id: 'mock_line_web_12345',
        name: 'Test LINE User',
        email: 'test.line.web@example.com',
        photoUrl: 'https://picsum.photos/200',
      );

      state = AuthState(
        status: AuthStatus.success,
        user: userModel,
      );

      debugPrint('LINE Mock Web Login Success');

      return;
    }

    const mockLineToken = 'mock_line_access_token';

    final result = await _repository.loginWithLine(
      accessToken: mockLineToken,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        status: AuthStatus.success,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.error,
      );
    }
  }

  // =======================
  // Register
  // =======================

  Future<void> register({
    required String role,
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );

    final result = await _repository.register(
      role: role,
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        status: AuthStatus.success,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.error,
      );
    }
  }

  // =======================
  // Google Login
  // =======================

  Future<void> loginWithGoogle({
    UserModel? selectedUser,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );

    if (selectedUser != null) {
      await Future.delayed(
        const Duration(milliseconds: 600),
      );

      state = AuthState(
        status: AuthStatus.success,
        user: selectedUser,
      );

      return;
    }

    final result = await _repository.loginWithGoogle();

    if (result.isSuccess) {
      final dynamic credential = result.data;

      UserModel userModel;

      if (credential != null && credential is UserCredential && credential.user != null) {
        final firebaseUser = credential.user!;

        userModel = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
        );
      } else if (result.data is UserModel) {
        userModel = result.data as UserModel;
      } else {
        userModel = UserModel(
          id: 'google_mock_user_1',
          name: 'Mock Google User',
          email: 'mock.google@example.com',
          photoUrl: 'https://i.pravatar.cc/150?img=11',
        );
      }

      state = AuthState(
        status: AuthStatus.success,
        user: userModel,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.error,
      );
    }
  }

  // =======================
  // Logout
  // =======================

  Future<void> logout() async {
    try {
      if (!kIsWeb) {
        await FacebookAuth.instance.logOut();
      }
    } catch (_) {}

    await _repository.logout();

    state = const AuthState(
      status: AuthStatus.idle,
      user: null,
    );
  }

  void resetState() {
    state = const AuthState();
  }
}

// =======================
// Provider
// =======================

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);