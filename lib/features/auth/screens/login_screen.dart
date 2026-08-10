import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../models/user_model.dart';
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

    ref
        .read(authProvider.notifier)
        .login(
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

  // ==============================
  // Google Mock Account Selector
  // ==============================

  void _showGoogleAccountChooser(BuildContext context) {
    final accounts = [
      UserModel(
        id: 'google_user_1',
        name: 'สมชาย สายลุย',
        email: 'somchai.dev@gmail.com',
        photoUrl: 'https://i.pravatar.cc/150?img=11',
      ),

      UserModel(
        id: 'google_user_2',
        name: 'Jane Doe',
        email: 'jane.doe@gmail.com',
        photoUrl: 'https://i.pravatar.cc/150?img=5',
      ),

      UserModel(
        id: 'google_user_3',
        name: 'MoveHub Tester',
        email: 'tester.movehub@gmail.com',
        photoUrl: 'https://i.pravatar.cc/150?img=68',
      ),
    ];

    showModalBottomSheet(
      context: context,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                const Text(
                  'เลือกบัญชี Google (Mock Mode)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ...accounts.map((account) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(account.photoUrl!),
                    ),

                    title: Text(account.name),

                    subtitle: Text(account.email),

                    onTap: () {
                      Navigator.pop(context);

                      ref
                          .read(authProvider.notifier)
                          .loginWithGoogle(selectedUser: account);
                    },
                  );
                }),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.login),

                  title: const Text('เข้าสู่ระบบด้วย Google SDK จริง'),

                  onTap: () {
                    Navigator.pop(context);

                    ref.read(authProvider.notifier).loginWithGoogle();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.status == AuthStatus.success) {
        ref.read(authProvider.notifier).resetState();

        context.go(AppRoutes.home);
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? AppStrings.error),

            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final loading = ref.watch(authProvider).status == AuthStatus.loading;

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

                Text(
                  AppStrings.appName,

                  textAlign: TextAlign.center,

                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.primary,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                CustomTextField(
                  label: AppStrings.email,
                  hintText: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return AppStrings.requiredField;
                    }

                    if (!v.contains('@')) {
                      return AppStrings.invalidEmail;
                    }

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
                    if (v == null || v.isEmpty) {
                      return AppStrings.requiredField;
                    }

                    if (v.length < 8) {
                      return AppStrings.passwordTooShort;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: loading ? null : _onLogin,

                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text(AppStrings.login),
                ),

                const SizedBox(height: 25),

                const Divider(),

                const SizedBox(height: 15),

                _SocialLoginButton(
                  label: 'Google',

                  backgroundColor: Colors.white,

                  foregroundColor: Colors.black,

                  icon: const Icon(Icons.g_mobiledata, size: 30),

                  onPressed: loading
                      ? null
                      : () {
                          _showGoogleAccountChooser(context);
                        },
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _SocialLoginButton(
                        label: 'Facebook',

                        backgroundColor: const Color(0xff1877F2),

                        foregroundColor: Colors.white,

                        icon: const Icon(Icons.facebook),

                        onPressed: loading ? null : _onLoginFacebook,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _SocialLoginButton(
                        label: 'LINE',

                        backgroundColor: const Color(0xff06C755),

                        foregroundColor: Colors.white,

                        icon: const Icon(Icons.chat),

                        onPressed: loading ? null : _onLoginLine,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    context.push(AppRoutes.register);
                  },

                  child: const Text(AppStrings.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =================================
// Social Button
// =================================

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

        padding: const EdgeInsets.symmetric(vertical: 14),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
