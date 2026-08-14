import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../shared/widgets/custom_text_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final currentLang = ref.read(languageProvider);
      final isEn = currentLang == AppLanguage.en;

      // Simulate API change password
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEn ? 'Password updated successfully' : 'เปลี่ยนรหัสผ่านเสร็จสิ้น',
            style: GoogleFonts.kanit(),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final isEn = currentLang == AppLanguage.en;
    final title = isEn ? 'Change Password' : 'เปลี่ยนรหัสผ่าน';
    final subtitle = isEn ? 'Secure your account' : 'เปลี่ยนรหัสผ่านเพื่อความปลอดภัย';
    
    final currentPassLabel = isEn ? 'Current Password' : 'รหัสผ่านปัจจุบัน';
    final newPassLabel = isEn ? 'New Password' : 'รหัสผ่านใหม่';
    final confirmPassLabel = isEn ? 'Confirm New Password' : 'ยืนยันรหัสผ่านใหม่';

    final currentHint = isEn ? 'Enter current password' : 'กรอกรหัสผ่านปัจจุบัน';
    final newHint = isEn ? 'Enter new password (min. 8 characters)' : 'กรอกรหัสผ่านใหม่ (อย่างน้อย 8 ตัวอักษร)';
    final confirmHint = isEn ? 'Confirm new password' : 'กรอกยืนยันรหัสผ่านใหม่';

    final requiredError = isEn ? 'This field is required' : 'กรุณากรอกข้อมูล';
    final minLengthError = isEn ? 'Password must be at least 8 characters' : 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
    final matchError = isEn ? 'Passwords do not match' : 'รหัสผ่านใหม่ไม่ตรงกัน';
    final saveButtonText = isEn ? 'Save Password' : 'บันทึกรหัสผ่านใหม่';

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF3F7FB);
    final cardBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // WAVE GRADIENT BLUE APPBAR
            // ==========================================
            ClipPath(
              clipper: ChangePasswordHeaderClipper(),
              child: Container(
                width: double.infinity,
                height: 155 + statusBarHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1C7FF6),
                      Color(0xFF0056C6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 0),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      bottom: 0,
                      child: Opacity(
                        opacity: 0.15,
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 96,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: () => context.pop(),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.kanit(
                                fontSize: 21,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: GoogleFonts.kanit(
                                fontSize: 12.5,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // INPUT FORM
            // ==========================================
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Password
                        CustomTextField(
                          label: currentPassLabel,
                          hintText: currentHint,
                          isPassword: true,
                          controller: _currentPasswordController,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return requiredError;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // New Password
                        CustomTextField(
                          label: newPassLabel,
                          hintText: newHint,
                          isPassword: true,
                          controller: _newPasswordController,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return requiredError;
                            }
                            if (val.trim().length < 8) {
                              return minLengthError;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Confirm New Password
                        CustomTextField(
                          label: confirmPassLabel,
                          hintText: confirmHint,
                          isPassword: true,
                          controller: _confirmPasswordController,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return requiredError;
                            }
                            if (val.trim() != _newPasswordController.text.trim()) {
                              return matchError;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1C7FF6),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              saveButtonText,
                              style: GoogleFonts.kanit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 15,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
