import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ค่าเริ่มต้นของการสมัคร
  String _role = 'customer';

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void _onRegister() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref
        .read(authProvider.notifier)
        .register(
          role: _role,
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (prev, next) {
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

    final isLoading = ref.watch(authProvider).status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.register),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // =========================
                // Role
                // =========================
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: const InputDecoration(
                    labelText: 'ประเภทบัญชี',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'customer', child: Text('ลูกค้า')),
                    DropdownMenuItem(value: 'driver', child: Text('คนขับ')),
                  ],
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _role = value;
                            });
                          }
                        },
                ),

                const SizedBox(height: AppDimensions.md),

                // =========================
                // Full Name
                // =========================
                CustomTextField(
                  label: 'ชื่อ-นามสกุล',
                  hintText: 'ลิขิต นาคหิต',
                  controller: _fullNameController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return AppStrings.requiredField;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.md),

                // =========================
                // Phone
                // =========================
                CustomTextField(
                  label: AppStrings.phone,
                  hintText: '0812345678',
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return AppStrings.requiredField;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.md),

                // =========================
                // Email
                // =========================
                CustomTextField(
                  label: AppStrings.email,
                  hintText: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return AppStrings.requiredField;
                    }

                    if (!v.contains('@')) {
                      return AppStrings.invalidEmail;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.md),

                // =========================
                // Password
                // =========================
                CustomTextField(
                  label: AppStrings.password,
                  hintText: '********',
                  isPassword: true,
                  controller: _passwordController,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return AppStrings.requiredField;
                    }

                    if (v.length < 6) {
                      return AppStrings.passwordTooShort;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.md),

                // =========================
                // Confirm Password
                // =========================
                CustomTextField(
                  label: AppStrings.confirmPassword,
                  hintText: '********',
                  isPassword: true,
                  controller: _confirmPasswordController,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return AppStrings.requiredField;
                    }

                    if (v != _passwordController.text) {
                      return 'รหัสผ่านไม่ตรงกัน';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.xl),

                // =========================
                // Register Button
                // =========================
                ElevatedButton(
                  onPressed: isLoading ? null : _onRegister,
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.white,
                          ),
                        )
                      : const Text(AppStrings.register),
                ),

                const SizedBox(height: AppDimensions.lg),

                // =========================
                // Divider
                // =========================
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'หรือ',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: AppDimensions.lg),

                // =========================
                // Google Register
                // =========================
                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          ref.read(authProvider.notifier).loginWithGoogle();
                        },
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('สมัครสมาชิกด้วย Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),

                const SizedBox(height: AppDimensions.lg),

                // =========================
                // Login Link
                // =========================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'มีบัญชีอยู่แล้ว?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(AppStrings.login),
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
