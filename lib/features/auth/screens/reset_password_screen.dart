import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ตั้งรหัสผ่านใหม่เรียบร้อยแล้ว กรุณาเข้าสู่ระบบด้วยรหัสผ่านใหม่',
                  style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );

      context.pushReplacement(AppRoutes.successVerification);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final isEn = currentLang == AppLanguage.en;

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
      ),
      body: Stack(
        children: [
          // Background ambient gradient blur
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1C7FF6).withValues(alpha: isDarkMode ? 0.35 : 0.18),
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_reset_rounded,
                            size: 42,
                            color: Color(0xFF1C7FF6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      isEn ? 'Set New Password' : 'ตั้งรหัสผ่านใหม่',
                      style: GoogleFonts.kanit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEn
                          ? 'Please enter your new password to secure your account.'
                          : 'กรุณากรอกรหัสผ่านใหม่สำหรับเข้าใช้งานบัญชีของคุณ',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        color: secondaryTextColor,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Card Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: cardBorderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // New Password Field
                          Text(
                            isEn ? 'New Password' : 'รหัสผ่านใหม่',
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.kanit(color: primaryTextColor, fontSize: 14),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return isEn ? 'Please enter new password' : 'กรุณากรอกรหัสผ่านใหม่';
                              }
                              if (val.trim().length < 8) {
                                return isEn ? 'Password must be at least 8 characters' : 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: isEn ? 'Enter new password (min. 8 chars)' : 'กรอกรหัสผ่านใหม่ (อย่างน้อย 8 ตัวอักษร)',
                              hintStyle: GoogleFonts.kanit(color: secondaryTextColor, fontSize: 13),
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF1C7FF6), size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: secondaryTextColor,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                              filled: true,
                              fillColor: inputBgColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF1C7FF6), width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Confirm Password Field
                          Text(
                            isEn ? 'Confirm New Password' : 'ยืนยันรหัสผ่านใหม่',
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: GoogleFonts.kanit(color: primaryTextColor, fontSize: 14),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return isEn ? 'Please confirm new password' : 'กรุณากรอกยืนยันรหัสผ่านใหม่';
                              }
                              if (val.trim() != _passwordController.text.trim()) {
                                return isEn ? 'Passwords do not match' : 'รหัสผ่านใหม่ไม่ตรงกัน';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: isEn ? 'Re-enter new password' : 'กรอกยืนยันรหัสผ่านใหม่อีกครั้ง',
                              hintStyle: GoogleFonts.kanit(color: secondaryTextColor, fontSize: 13),
                              prefixIcon: const Icon(Icons.lock_clock_outlined, color: Color(0xFF1C7FF6), size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: secondaryTextColor,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                },
                              ),
                              filled: true,
                              fillColor: inputBgColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF1C7FF6), width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1C7FF6),
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _isLoading ? null : _onSubmit,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          isEn ? 'Save New Password' : 'บันทึกรหัสผ่านใหม่',
                                          style: GoogleFonts.kanit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward_rounded, size: 20),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
