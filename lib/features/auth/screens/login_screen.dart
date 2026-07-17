import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  void _onLoginFacebook() {
    ref.read(authProvider.notifier).loginWithFacebook();
  }

  void _onLoginLine() {
    ref.read(authProvider.notifier).loginWithLine();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.success) {
        ref.read(authProvider.notifier).resetState();
        context.go(AppRoutes.home);
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? AppStrings.error),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final isLoading =
        ref.watch(authProvider).status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.xxl),

                // ===== Logo / App Name =====
                Center(
                  child: Text(
                    AppStrings.appName,
                        style:
                        Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    AppStrings.appDescription,
                    style:
                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppDimensions.xxl),

                // ===== Form =====
                CustomTextField(
                  label: AppStrings.email,
                  hintText: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppStrings.requiredField;
                    if (!v.contains('@')) return AppStrings.invalidEmail;
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.md),
                CustomTextField(
                  label: AppStrings.password,
                  hintText: '********',
                  isPassword: true,
                  controller: _passwordController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppStrings.requiredField;
                    if (v.length < 8) return AppStrings.passwordTooShort;
                    return null;
                  },
                ),

                // ===== Forgot Password =====
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(AppStrings.forgotPassword),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),

                // ===== Login Button =====
                ElevatedButton(
                  onPressed: isLoading ? null : _onLogin,
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.white,
                          ),
                        )
                      : const Text(AppStrings.login),
                ),
                const SizedBox(height: AppDimensions.xl),

                // ===== Divider: OR =====
                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm),
                      child: Text(
                        'หรือเข้าสู่ระบบด้วย',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: AppDimensions.lg),

                // ===== Google Login Button =====
                _SocialLoginButton(
                  label: 'Google',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textPrimary,
                  icon: const Icon(Icons.g_mobiledata, size: 28, color: AppColors.textPrimary),
                  onPressed: isLoading
                      ? null
                      : () {
                          ref.read(authProvider.notifier).loginWithGoogle();
                        },
                ),
                const SizedBox(height: AppDimensions.md),

                // ===== Social Login Buttons =====
                Row(
                  children: [
                    // Facebook Button
                    Expanded(
                      child: _SocialLoginButton(
                        label: 'Facebook',
                        backgroundColor: const Color(0xFF1877F2),
                        foregroundColor: Colors.white,
                        icon: Image.asset(
                          'assets/images/facebook.png',
                          width: 22,
                          height: 22,
                        ),
                        onPressed: isLoading ? null : _onLoginFacebook,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    // LINE Button
                    Expanded(
                      child: _SocialLoginButton(
                        label: 'LINE',
                        backgroundColor: const Color(0xFF06C755),
                        foregroundColor: Colors.white,
                        icon: Image.asset(
                          'assets/images/line.png',
                          width: 22,
                          height: 22,
                        ),
                        onPressed: isLoading ? null : _onLoginLine,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.xl),

                // ===== Register Link =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ยังไม่มีบัญชีใช่หรือไม่?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.register),
                      child: const Text(AppStrings.register),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Social Login Button Widget
// ============================================================

class _SocialLoginButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget icon;
  final VoidCallback? onPressed;

  const _SocialLoginButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 2,
        shadowColor: backgroundColor.withAlpha(100),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}




