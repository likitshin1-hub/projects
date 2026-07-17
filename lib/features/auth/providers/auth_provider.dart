import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository.dart';

// ===== State =====

enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
  });

  AuthState copyWith({AuthStatus? status, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
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
    await _repository.logout();
    resetState();
  }

  void resetState() {
    state = const AuthState();
  }
}

// ===== Provider =====

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
