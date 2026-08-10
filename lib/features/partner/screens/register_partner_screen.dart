import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';

class RegisterPartnerScreen extends ConsumerStatefulWidget {
  const RegisterPartnerScreen({super.key});

  @override
  ConsumerState<RegisterPartnerScreen> createState() => _RegisterPartnerScreenState();
}

class _RegisterPartnerScreenState extends ConsumerState<RegisterPartnerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licensePlateController = TextEditingController();
  String _selectedVehicle = 'รถกระบะ';
  bool _acceptedTerms = false;
  bool _isLoading = false;

  final List<String> _vehicleTypes = [
    'มอเตอร์ไซค์',
    'รถเก๋ง 4 ประตู',
    'รถกระบะ',
    'รถห้องเย็น',
    'รถบรรทุกมีลิฟท์ท้าย',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  void _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'กรุณายอมรับเงื่อนไขการเป็นพาร์ทเนอร์คนขับก่อนดำเนินการ',
            style: GoogleFonts.kanit(),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);

    // Update user role to driver
    final currentUser = ref.read(authProvider).user;
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(role: 'driver');
      ref.read(authProvider.notifier).updateUser(updatedUser);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ลงทะเบียนพาร์ทเนอร์คนขับสำเร็จแล้ว!',
          style: GoogleFonts.kanit(),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.go(AppRoutes.driver);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Google Ambient Glow Blobs
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? const Color(0xFF10B981).withValues(alpha: 0.18)
                    : const Color(0xFF34D399).withValues(alpha: 0.22),
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? const Color(0xFF0284C7).withValues(alpha: 0.18)
                    : const Color(0xFF38BDF8).withValues(alpha: 0.22),
              ),
            ),
          ),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
            child: Container(color: Colors.transparent),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: textColor,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.home);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Header Title
                    Text(
                      'สมัครพาร์ทเนอร์คนขับ 🚚',
                      style: GoogleFonts.kanit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ร่วมสร้างรายได้กับ TBMoveHub ขับง่าย ได้เงินไว อิสระทุกช่วงเวลา',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: 'ชื่อ-นามสกุล ผู้สมัคร',
                            hintText: 'กรอกชื่อและนามสกุลจริง',
                            controller: _nameController,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'กรุณากรอกชื่อ-นามสกุล';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            label: 'เบอร์โทรศัพท์ติดต่อ',
                            hintText: '08X-XXX-XXXX',
                            keyboardType: TextInputType.phone,
                            controller: _phoneController,
                            validator: (val) {
                              if (val == null || val.trim().length < 9) {
                                return 'กรุณากรอกเบอร์โทรศัพท์ที่ถูกต้อง';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'ประเภท ยานพาหนะ',
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedVehicle,
                            dropdownColor: cardColor,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDarkMode
                                  ? const Color(0xFF0B0F17)
                                  : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                            items: _vehicleTypes.map((v) {
                              return DropdownMenuItem(
                                value: v,
                                child: Text(
                                  v,
                                  style: GoogleFonts.kanit(color: textColor),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedVehicle = val);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            label: 'หมายเลขป้ายทะเบียนรถ',
                            hintText: 'เช่น 1กข-8899 กรุงเทพฯ',
                            controller: _licensePlateController,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'กรุณากรอกป้ายทะเบียนรถ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Checkbox(
                                value: _acceptedTerms,
                                activeColor: const Color(0xFF10B981),
                                onChanged: (val) {
                                  setState(() => _acceptedTerms = val ?? false);
                                },
                              ),
                              Expanded(
                                child: Text(
                                  'ฉันยอมรับข้อตกลงและเงื่อนไขการเป็นพาร์ทเนอร์คนขับ',
                                  style: GoogleFonts.kanit(
                                    fontSize: 12.5,
                                    color: subTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _isLoading ? null : _submitRegistration,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'ยืนยันสมัครพาร์ทเนอร์',
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
                    const SizedBox(height: 30),
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
