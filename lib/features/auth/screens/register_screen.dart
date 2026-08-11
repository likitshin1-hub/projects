import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/theme_provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: 'ลิขิต');
  final _lastNameController = TextEditingController(text: 'ยอดคน');
  final _emailController = TextEditingController(text: 'tbmovehub@gmail.com');
  final _phoneController = TextEditingController(text: '0812345678');
  final _passwordController = TextEditingController(text: '12345678');
  final _confirmPasswordController = TextEditingController(text: '12345678');
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = true;

  // ค่าเริ่มต้นของการสมัคร
  String _role = 'customer';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void _onRegister() {
    final firstName = _firstNameController.text.trim().isEmpty ? 'ลิขิต' : _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim().isEmpty ? 'ยอดคน' : _lastNameController.text.trim();
    final phone = _phoneController.text.trim().isEmpty ? '0812345678' : _phoneController.text.trim();
    final email = _emailController.text.trim().isEmpty ? 'tbmovehub@gmail.com' : _emailController.text.trim();
    final password = _passwordController.text.isEmpty ? '12345678' : _passwordController.text;

    ref.read(authProvider.notifier).register(
          fullName: '$firstName $lastName',
          phone: phone,
          email: email,
          password: password,
          confirmPassword: password,
          role: 'customer',
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
            content: Text(
              next.errorMessage ?? AppStrings.error,
              style: GoogleFonts.kanit(),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
      }
    });

    final isLoading = ref.watch(authProvider).status == AuthStatus.loading;
    final isDarkMode = ref.watch(themeProvider);

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC);
    final cardBgColor = isDarkMode
        ? const Color(0xFF1E293B).withValues(alpha: 0.65)
        : Colors.white.withValues(alpha: 0.85);
    final cardBorderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.1)
        : const Color(0xFFE2E8F0);
    final primaryTextColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final inputBgColor = isDarkMode
        ? const Color(0xFF0F172A).withValues(alpha: 0.6)
        : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryTextColor, size: 20),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'สมัครสมาชิก',
          style: GoogleFonts.kanit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          // ===== Google-Style Ambient Glow =====
          Positioned(
            top: -80,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: isDarkMode ? 0.3 : 0.18),
                    const Color(0xFF3B82F6).withValues(alpha: isDarkMode ? 0.15 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: isDarkMode ? 0.3 : 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: Colors.transparent),
            ),
          ),

          // ===== Main Scroll Content =====
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'สร้างบัญชีใหม่',
                    style: GoogleFonts.kanit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'กรอกข้อมูลให้ครบถ้วนเพื่อเริ่มใช้งานบริการจัดส่งสินค้า',
                    style: GoogleFonts.kanit(
                      fontSize: 13,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Glassmorphism Card
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: cardBorderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('ชื่อ', primaryTextColor),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _firstNameController,
                                      style: GoogleFonts.kanit(fontSize: 14, color: primaryTextColor),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return AppStrings.requiredField;
                                        return null;
                                      },
                                      decoration: _buildInputDecoration(
                                        hint: 'ชื่อจริง',
                                        icon: Icons.person_outline_rounded,
                                        inputBgColor: inputBgColor,
                                        borderColor: cardBorderColor,
                                        secondaryTextColor: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('นามสกุล', primaryTextColor),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _lastNameController,
                                      style: GoogleFonts.kanit(fontSize: 14, color: primaryTextColor),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return AppStrings.requiredField;
                                        return null;
                                      },
                                      decoration: _buildInputDecoration(
                                        hint: 'นามสกุล',
                                        icon: Icons.person_outline_rounded,
                                        inputBgColor: inputBgColor,
                                        borderColor: cardBorderColor,
                                        secondaryTextColor: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildFieldLabel('อีเมล', primaryTextColor),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.kanit(fontSize: 14, color: primaryTextColor),
                            validator: (v) {
                              if (v == null || v.isEmpty) return AppStrings.requiredField;
                              if (!v.contains('@')) return AppStrings.invalidEmail;
                              return null;
                            },
                            decoration: _buildInputDecoration(
                              hint: 'tbmovehub@gmail.com',
                              icon: Icons.mail_outline_rounded,
                              inputBgColor: inputBgColor,
                              borderColor: cardBorderColor,
                              secondaryTextColor: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildFieldLabel('เบอร์โทรศัพท์', primaryTextColor),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.kanit(fontSize: 14, color: primaryTextColor),
                            validator: (v) {
                              if (v == null || v.isEmpty) return AppStrings.requiredField;
                              return null;
                            },
                            decoration: _buildInputDecoration(
                              hint: '08X.XXX.XXXX',
                              icon: Icons.phone_outlined,
                              inputBgColor: inputBgColor,
                              borderColor: cardBorderColor,
                              secondaryTextColor: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),



                          _buildFieldLabel('รหัสผ่าน', primaryTextColor),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.kanit(fontSize: 14, color: primaryTextColor),
                            validator: (v) {
                              if (v == null || v.isEmpty) return AppStrings.requiredField;
                              if (v.length < 8) return AppStrings.passwordTooShort;
                              return null;
                            },
                            decoration: _buildInputDecoration(
                              hint: 'อย่างน้อย 8 ตัวอักษร',
                              icon: Icons.lock_outline_rounded,
                              inputBgColor: inputBgColor,
                              borderColor: cardBorderColor,
                              secondaryTextColor: secondaryTextColor,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: secondaryTextColor,
                                  size: 18,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildFieldLabel('ยืนยันรหัสผ่าน', primaryTextColor),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: GoogleFonts.kanit(fontSize: 14, color: primaryTextColor),
                            validator: (v) {
                              if (v == null || v.isEmpty) return AppStrings.requiredField;
                              if (v != _passwordController.text) return 'รหัสผ่านไม่ตรงกัน';
                              return null;
                            },
                            decoration: _buildInputDecoration(
                              hint: 'กรอกรหัสผ่านอีกครั้ง',
                              icon: Icons.lock_outline_rounded,
                              inputBgColor: inputBgColor,
                              borderColor: cardBorderColor,
                              secondaryTextColor: secondaryTextColor,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: secondaryTextColor,
                                  size: 18,
                                ),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Terms Checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _acceptTerms,
                                  activeColor: const Color(0xFF0284C7),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final accepted = await context.push<bool>(AppRoutes.terms);
                                    if (accepted == true) {
                                      setState(() => _acceptTerms = true);
                                    }
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.kanit(fontSize: 13, color: secondaryTextColor, height: 1.4),
                                      children: [
                                        const TextSpan(text: 'ข้าพเจ้ายินยอมและยอมรับ '),
                                        TextSpan(
                                          text: 'เงื่อนไขการให้บริการ',
                                          style: GoogleFonts.kanit(color: const Color(0xFF0284C7), fontWeight: FontWeight.w600),
                                        ),
                                        const TextSpan(text: ' และ '),
                                        TextSpan(
                                          text: 'นโยบายความเป็นส่วนตัว',
                                          style: GoogleFonts.kanit(color: const Color(0xFF0284C7), fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Register Submit Button
                          SizedBox(
                            height: 52,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _onRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                      )
                                    : Text(
                                        'ยืนยันสมัครสมาชิก',
                                        style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('มีบัญชีผู้ใช้แล้ว? ', style: GoogleFonts.kanit(color: secondaryTextColor, fontSize: 14)),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'เข้าสู่ระบบ',
                          style: GoogleFonts.kanit(color: const Color(0xFF0284C7), fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, Color color) {
    return Text(
      label,
      style: GoogleFonts.kanit(color: color, fontWeight: FontWeight.w600, fontSize: 13),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    required Color inputBgColor,
    required Color borderColor,
    required Color secondaryTextColor,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.kanit(color: secondaryTextColor, fontSize: 13),
      prefixIcon: Icon(icon, color: secondaryTextColor, size: 18),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: inputBgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
      ),
    );
  }
}
